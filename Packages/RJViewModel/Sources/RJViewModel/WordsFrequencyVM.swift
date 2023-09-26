
import Foundation
import Combine
import OSLog

import RJServices

public extension WordsFrequencyVM {
	
	// MARK: - Nested Types
	
	/// Represents the state of the view model.
	enum State: Equatable {
		case initial
		case updateStarted
		case countingWords
		case buildingIndex
		case updatingRows
		case finished
		case cancelled
		case error(description: String)
	}
	
	/// Represents an item in the word frequency list.
	typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
}

/// Represents the view model for handling word frequencies.
public final class WordsFrequencyVM {
	
	// MARK: - Public
	
	/// The screen name associated with the view model (for analytics purposes).
	public var screenName = "WordsFrequency"
	
	public var loadingInProgress: Bool { updateRowsTask != nil || resetTask != nil }
	
	/// The provider of text content to be analyzed for word frequencies.
	public private(set) var textProvider: TextProvider

	/// The configuration details used for counting words.
	public private(set) var configuration: WordsCounterConfiguration

	/// The key that determines how word frequencies are sorted.
	public private(set) var sortingKey: WordFrequencySortingKey

	/// The current state of the view model.
	public private(set) var state = CurrentValueSubject<State, Never>(.initial)

	/// The list of word-frequency items to be displayed.
	public private(set) var rowItems = CurrentValueSubject<[Item], Never>([])
	
	// MARK: - Private
	typealias IndexTable = [WordFrequencyMap.Key]
	private var indexTablesCache = [WordFrequencySortingKey: IndexTable]()
	private var frequencyMapCache: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	private var analytics: Analytics?
	
	private var updateRowsTask: Task<Void, Never>? = nil
	private var updateQueued: Bool = false
	
	private var resetTask: Task<Void, Never>? = nil
	
	private var cancellables = Set<AnyCancellable>()
	private let logger = Logger(subsystem: "RJViewModel", category: "WordsFrequencyVM")
	
	// MARK: - Init
	
	public init(
		_ textProvider: TextProvider,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics? = nil,
		configuration: WordsCounterConfiguration = .init(.alphanumericWithDashesAndApostrophes),
		initialSortingKey: WordFrequencySortingKey = .mostFrequent
	) {
		self.textProvider = textProvider
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
		self.sortingKey = initialSortingKey
		self.configuration = configuration
		
		self.setupLogging()
	}

}

// MARK: - Methods
// MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		analytics?.screen(screenName)
		if state.value == .initial {
			requestRowsUpdate(overwriteCurrentTask: false)
		}
	}
	
	func onIndexKeyChanged(_ newKey: WordFrequencySortingKey) {
		guard sortingKey != newKey else { return }
		
		sendIndexChangedEvent(from: sortingKey, to: newKey)
		sortingKey = newKey
		requestRowsUpdate()
	}
	
	func onTextProviderChange(to newTextProvider: TextProvider) {
		textProvider = newTextProvider
		requestRowsUpdate(clearCache: true)
	}
	
	func onConfigChange(to newConfig: WordsCounterConfiguration) {
		configuration = newConfig
		requestRowsUpdate(clearCache: true)
	}
}

// MARK: - Private
private extension WordsFrequencyVM {
	
	// MARK: - Loading data
	
	func requestRowsUpdate(
		overwriteCurrentTask: Bool = true,
		clearCache: Bool = false
	) {
		guard updateRowsTask == nil else {
			if overwriteCurrentTask {
				updateQueued = true
				updateRowsTask?.cancel()
			}
			return
		}
		
		state.send(.updateStarted)
		updateRowsTask = Task { [weak self] in
			guard let self else { return }
			
			if clearCache {
				self.clearCache()
			}
			
			do { try await self.updateRowItems() }
			catch { self.handle(error: error) }
			
			self.updateRowsTask = nil
			if self.updateQueued {
				self.updateQueued = false
				requestRowsUpdate(overwriteCurrentTask: false)
			}
		}
	}
	
	func updateRowItems() async throws {
		let frequencyMap = try await self.lazilyLoadedFrequencyMap()
		guard !Task.isCancelled else { throw CancellationError() }

		let indexTable = await self.lazilyLoadedIndex(frequencyMap, sortingKey)
		guard !Task.isCancelled else { throw CancellationError() }
		
		let updatedItems = try buildRowItems(map: frequencyMap, indexTable: indexTable)
		guard !Task.isCancelled else { throw CancellationError() }

		self.rowItems.send(updatedItems)
		self.state.send(.finished)
	}
	
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if let frequencyMapCache { return frequencyMapCache }
		
		state.send(.countingWords)
		let text = try await textProvider.text
		let result = try await wordCounter.countWords(text, config: configuration)
		frequencyMapCache = result
		return result
	}
	
	func lazilyLoadedIndex(_ map: WordFrequencyMap, _ key: WordFrequencySortingKey) async -> IndexTable {
		if let cachedTable = indexTablesCache[key] { return cachedTable }
		
		state.send(.buildingIndex)
		let result = await indexBuilder.build(map, index: key)
		indexTablesCache[key] = result
		return result
	}
	
	func buildRowItems(map: WordFrequencyMap, indexTable: IndexTable) throws -> [Item] {
		self.state.send(.updatingRows)
		return try indexTable.map { word in
			guard let frequency = map[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
			return Item(word: word, frequency: frequency)
		}
	}

	// MARK: - Misc

	func clearCache() {
		indexTablesCache = [WordFrequencySortingKey: IndexTable]()
		frequencyMapCache = nil
		rowItems.send([])
	}
	
	func handle(error: Error) {
		if error is CancellationError {
			state.send(.cancelled)
		} else {
			let userMessage = error.localizedDescription
			state.send(.error(description: userMessage))
			
			let devDescription = error.localizedDescription
			logger.error("\(devDescription)")
			
			analytics?.error(error)
		}
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
	
	func sendIndexChangedEvent(
		from: WordFrequencySortingKey,
		to: WordFrequencySortingKey
	) {
		analytics?.event("indexKeyChaged", context: [
			"from": from,
			"to": to,
			"screen": screenName])
	}
}

