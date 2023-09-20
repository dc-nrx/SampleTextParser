
import Foundation
import RJCore
import Combine

public extension WordsFrequencyVM {
	
	enum State: Equatable {
		case initial, updateStarted, countingWords, buildingIndex, updatingRows, finished, error(description: String)
	}
	
	typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
}

public final class WordsFrequencyVM {
	
	// MARK: - Public
	
	//TODO: Make var / clear cache on change
	public let data: Data
	
	public private(set) var indexKey: WordFrequencyIndexKey

	public private(set) var state = CurrentValueSubject<State, Never>(.initial)
	public private(set) var rowItems = CurrentValueSubject<[Item], Never>([])
		
	// MARK: - Private
	typealias IndexTable = [WordFrequencyMap.Key]
	var indexTablesCache = [WordFrequencyIndexKey: IndexTable]()
	var frequencyMapCache: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	private var analytics: Analytics
		
	// MARK: - Init
	public init(
		_ data: Data,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics,
		initialIndexKey: WordFrequencyIndexKey = .mostFrequent
	) {
		self.data = data
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
		self.indexKey = initialIndexKey
	}

}

// MARK: - Methods
// MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		loadData(for: indexKey)
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
		let result = try await wordCounter.countWords(textData: data, matchPattern: .alphanumericWithDashesAndApostrophes)
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
	
	func handle(error: Error) {
		state.send(.error(description: error.localizedDescription))
		analytics.error(error)
	}
}

