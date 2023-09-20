
import Foundation
import RJCore

public final class WordsFrequencyVM {
	
	// MARK: - Public
	
	//TODO: Make var / clear cache on change
	public let data: Data
	
	public var indexKey: WordFrequencyIndexKey = .mostFrequent {
		didSet {
			if oldValue != indexKey {
				loadData(for: indexKey)
			}
		}
	}
	
	public enum State: Equatable {
		case initial, updateStarted, countingWords, buildingIndex, updatingRows, finished, error(description: String)
	}
	public private(set) var state = State.initial
	
	public typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
	public private(set) var rowItems = [Item]()
		
	// MARK: - Private
	typealias IndexTable = [WordFrequencyMap.Key]
	var indexTables = [WordFrequencyIndexKey: IndexTable]()
	var frequencyMap: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	private var analytics: Analytics
		
	// MARK: - Init
	public init(
		_ data: Data,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics
	) {
		self.data = data
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
	}

}

// MARK: - Methods
// MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		loadData(for: indexKey)
	}
	
	func onIndexKeyChanged(_ newKey: WordFrequencyIndexKey) {
		indexKey = newKey
	}
}

// MARK: - Private
private extension WordsFrequencyVM {
	
	// MARK: - Logic
	
	private var updateInProgress: Bool {
		if case .error(_) = state { return false }
		if state == .initial || state == .finished { return false }
		
		return true
	}

	//TODO: Add cancellation before each step
	func loadData(for newKey: WordFrequencyIndexKey) {
		guard !updateInProgress else { return }
		state = .updateStarted
		Task {
			do {
				let unwrappedFrequencyMap = try await lazilyLoadedFrequencyMap()
				let indexTable = try await lazilyLoadedIndex(unwrappedFrequencyMap, newKey)
				
				state = .updatingRows
				rowItems = try indexTable.map { word in
					guard let frequency = unwrappedFrequencyMap[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
					return Item(word: word, frequency: frequency)
				}
				state = .finished
			} catch {
				handle(error: error)
			}
		}
	}
	
	//TODO: Make a property wrapper @AsyncVar
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if frequencyMap == nil {
			state = .countingWords
			//TODO: Make match pattern a parameter
			frequencyMap = try await wordCounter.countWords(textData: data, matchPattern: .alphanumericWithDashesAndApostrophes)
		}
		guard let frequencyMap else { throw GenericError.unexpectedNil(file: #file, line: #line) }
		return frequencyMap
	}
	
	func lazilyLoadedIndex(_ map: WordFrequencyMap, _ key: WordFrequencyIndexKey) async throws -> IndexTable {
		if indexTables[key] == nil {
			state = .buildingIndex
			indexTables[key] = await indexBuilder.build(map, index: key)
		}
		guard let indexTable = indexTables[key] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
		return indexTable
	}

	// MARK: - Misc
	
	func handle(error: Error) {
		state = .error(description: error.localizedDescription)
		analytics.error(error)
	}
}

