
import Foundation
import RJCore
import Combine
import OSLog

public extension WordsFrequencyVM {
	
	enum State: Equatable {
		case initial, updateStarted, countingWords, buildingIndex, updatingRows, finished, reset, error(description: String)
	}
	
	typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
}

public final class WordsFrequencyVM {
	
	// MARK: - Public
	//TODO: Make var / clear cache on change
	public let data: Data
	
	public private(set) var indexKey: WordFrequencyIndexKey
	public private(set) var postProcessRule: WordPostProcessor?
	
	public private(set) var state = CurrentValueSubject<State, Never>(.initial)
	public private(set) var rowItems = CurrentValueSubject<[Item], Never>([])
		
	// MARK: - Private
	typealias IndexTable = [WordFrequencyMap.Key]
	private var indexTablesCache = [WordFrequencyIndexKey: IndexTable]()
	private var frequencyMapCache: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	private var analytics: Analytics?
	
	private var cancellables = Set<AnyCancellable>()
	private let logger = Logger(subsystem: "RJViewModel", category: "WordsFrequencyVM")
		
	// MARK: - Init
	public init(
		_ data: Data,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics? = nil,
		initialIndexKey: WordFrequencyIndexKey = .mostFrequent
	) {
		self.data = data
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
		self.indexKey = initialIndexKey
		
		self.setupLogging()
	}

}

// MARK: - Methods
// MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		if state.value == .initial {
			loadData(for: indexKey)
		}
	}
	
	func onIndexKeyChanged(_ newKey: WordFrequencyIndexKey) {
		if indexKey != newKey {
			indexKey = newKey
			loadData(for: indexKey)
		}
	}
}

// MARK: - Private
private extension WordsFrequencyVM {
	
	// MARK: - Logic
	
	private var updateInProgress: Bool {
		if state.value == .initial || state.value == .finished { return false }
		else if case .error(_) = state.value { return false }
		else { return true }
	}

	//TODO: Add cancellation before each step
	func loadData(for newKey: WordFrequencyIndexKey) {
		guard !updateInProgress else { return }
		state.send(.updateStarted)
		Task {
			do {
				let frequencyMap = try await lazilyLoadedFrequencyMap()
				let indexTable = await lazilyLoadedIndex(frequencyMap, newKey)
				
				state.send(.updatingRows)
				let updatedItems = try indexTable.map { word in
					guard let frequency = frequencyMap[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
					return Item(word: word, frequency: frequency)
				}
				rowItems.send(updatedItems)
				state.send(.finished)
			} catch {
				handle(error: error)
			}
		}
	}
	
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if let frequencyMapCache { return frequencyMapCache }
		
		state.send(.countingWords)
		//TODO: Make match pattern a parameter
		let result = try await wordCounter.countWords(textData: data, matchPattern: .alphanumericWithDashesAndApostrophes, wordPostProcessor: postProcessRule)
		frequencyMapCache = result
		return result
	}
	
	func lazilyLoadedIndex(_ map: WordFrequencyMap, _ key: WordFrequencyIndexKey) async -> IndexTable {
		if let cachedTable = indexTablesCache[key] { return cachedTable }
		
		state.send(.buildingIndex)
		let result = await indexBuilder.build(map, index: key)
		indexTablesCache[key] = result
		return result
	}

	// MARK: - Misc
	
	func reset() {
		indexTablesCache = [WordFrequencyIndexKey: IndexTable]()
		frequencyMapCache = nil
		rowItems.send([])
		state.send(.reset)
	}
	
	func handle(error: Error) {
		let userMessage = error.localizedDescription
		state.send(.error(description: userMessage))
		
		let devDescription = error.localizedDescription
		logger.error("\(devDescription)")
		
		analytics?.error(error)
	}
	
	func setupLogging() {
		state.sink { [weak self] state in
			let stateName = "\(state)"
			self?.logger.debug("State changed to \(stateName)")
		}
		.store(in: &cancellables)
		
		rowItems.sink { [weak self] items in
			self?.logger.debug("\(items.count) row items sent")
		}
		.store(in: &cancellables)
	}
}

