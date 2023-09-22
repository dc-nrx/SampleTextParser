
import Foundation
import Combine
import OSLog

import RJServices

public extension WordsFrequencyVM {
	
	enum State: Equatable {
		case initial, updateStarted, countingWords, buildingIndex, updatingRows, finished, cancelled, reset, error(description: String)
		
		var updateInProgress: Bool {
			switch self {
			case .initial, .finished, .cancelled, .reset, .error(_):
				return false
			default:
				return true
			}
		}
	}
	
	typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
}

public final class WordsFrequencyVM {
	
	// MARK: - Public
	//TODO: Make var / clear cache on change
	public let text: String
	
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
	private var updateTask: Task<Void, Never>? = nil
	
	// MARK: - Init
	public init(
		_ text: String,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics? = nil,
		initialIndexKey: WordFrequencyIndexKey = .mostFrequent
	) {
		self.text = text
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
	
	//TODO: Add cancellation before each step
	func loadData(for newKey: WordFrequencyIndexKey) {
		guard !state.value.updateInProgress else { return }
		
		state.send(.updateStarted)
		updateTask = Task { [weak self] in
			guard let self else { return }
			do {
				let frequencyMap = try await self.lazilyLoadedFrequencyMap()
				let indexTable = await self.lazilyLoadedIndex(frequencyMap, newKey)
				guard !Task.isCancelled else {
					self.state.send(.cancelled)
					return
				}
				
				self.state.send(.updatingRows)
				let updatedItems = try indexTable.map { word in
					guard let frequency = frequencyMap[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
					return Item(word: word, frequency: frequency)
				}

				self.rowItems.send(updatedItems)
				self.state.send(.finished)
			} catch {
				handle(error: error)
			}
		}
	}
	
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if let frequencyMapCache { return frequencyMapCache }
		
		state.send(.countingWords)
		//TODO: Make match pattern a parameter
		let result = try await wordCounter.countWords(text, matchPattern: .alphanumericWithDashesAndApostrophes, wordPostProcessor: postProcessRule)
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
			self?.logger.info("Items = \(items.prefix(8))(...)")
		}
		.store(in: &cancellables)
	}
}

