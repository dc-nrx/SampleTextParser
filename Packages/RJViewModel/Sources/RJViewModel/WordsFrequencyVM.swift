
import Foundation
import RJCore

public final class WordsFrequencyVM {
	
	//MARK: - Public
	
	//TODO: Make var / clear cache on change
	public let data: Data
	public var indexKey: WordFrequencyIndexKey = .mostFrequent {
		didSet {
			if oldValue != indexKey {
				loadData(for: indexKey)
			}
		}
	}
	
	public enum State {
		case initial, processing, buildingIndex, finished
	}
	public private(set) var state = State.initial
	
	public typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
	public private(set) var rowItems = [Item]()
		
	//MARK: - Private
	var indexTables = [WordFrequencyIndexKey: [WordFrequencyMap.Key]]()
	var frequencyMap: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	
	//MARK: - Init
	public init(
		_ data: Data,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder
	) {
		self.data = data
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
	}

}

//MARK: - Methods
//MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		
	}
	
	func onIndexKeyChanged(_ newKey: WordFrequencyIndexKey) {
		indexKey = newKey
	}
}

//MARK: - Private
private extension WordsFrequencyVM {
	
	//TODO: Make a property wrapper @AsyncVar
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if frequencyMap == nil {
			//TODO: Make match pattern a parameter
			frequencyMap = try await wordCounter.countWords(textData: data, matchPattern: .alphanumericWithDashesAndApostrophes)
		}
		return frequencyMap!
	}
	
	//TODO: Add cancellation at each step
	func loadData(for newKey: WordFrequencyIndexKey) {
		Task {
			let map = try await lazilyLoadedFrequencyMap()
			if indexTables[newKey] == nil {
				indexTables[newKey] = await indexBuilder.build(map, index: newKey)
			}
			guard let indexTable = indexTables[newKey] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
			rowItems = try indexTable.map { word in
				guard let frequency = map[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
				return Item(word: word, frequency: frequency)
			}
		}
	}
	
	func handle(error: Error) {
		//TODO: Add var / show it in view
	}
}

