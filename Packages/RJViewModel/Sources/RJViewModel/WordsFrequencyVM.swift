
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
	
	/// Represents a marker whether `requestRowsUpdate` should be called
	/// once more after finish / cancelletion of the currently executing one.
	private enum QueuedRequest: Int, Comparable {
		case none = 0
		case usingExistedCache
		case clearingCache
		
		public static func < (lhs: QueuedRequest, rhs: QueuedRequest) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}
	}
}

/// Represents the view model for handling word frequencies.
public final class WordsFrequencyVM {
	
	// MARK: - Public
	
	/// The screen name associated with the view model (for analytics purposes).
	public var screenName = "WordsFrequency"
	
	public var loadingInProgress: Bool { updateRowsTask != nil }
	
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
	private var queuedRequest: QueuedRequest = .none
	
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
	
	func onSortingKeyChanged(_ newKey: WordFrequencySortingKey) {
		guard sortingKey != newKey else { return }
		
		sendSortingKeyChangedEvent(from: sortingKey, to: newKey)
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
	
	/**
	 Requests an update for row items.

	 Depending on the parameters provided, this method can either:
	 - Use the existing cache
	 - Clear and rebuild the cache
	 - Overwrite the current task, if it's ongoing, by cancelling it and queing a subsequent execution request.
	 In case of multiple overwrite requests, the strictest one takes priority (e.g. the one with `clearCache`, in
	 case it has been requested at any point)

	 - Parameters:
	   - overwriteCurrentTask: A flag indicating whether the current update task should be overwritten if there's one ongoing. Default is `true`.
	   - clearCache: A flag indicating if the cache should be cleared before updating the rows. Default is `false`.
	 */
	func requestRowsUpdate(
		overwriteCurrentTask: Bool = true,
		clearCache: Bool = false
	) {
		guard updateRowsTask == nil else {
			if overwriteCurrentTask {
				let currentRequest: QueuedRequest = clearCache ? .clearingCache : .usingExistedCache
				queuedRequest = max(queuedRequest, currentRequest)
				updateRowsTask?.cancel()
			}
			return
		}
		
		state.send(.updateStarted)
		updateRowsTask = Task { [weak self] in
			guard let self else { return }
			
			if clearCache { self.clearCache() }
			
			do { try await self.updateRowItems() }
			catch { self.handle(error: error) }
			
			self.updateRowsTask = nil
			executeQueuedRequestIfNeeded()
		}
	}
	
	/// The core method to update the `rowItems`.
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
	
	/// Shold be called from `updateRowItems`  only to preserve correct state updates.
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if let frequencyMapCache { return frequencyMapCache }
		
		state.send(.countingWords)
		let text = try await textProvider.text
		let result = try await wordCounter.countWords(text, config: configuration)
		frequencyMapCache = result
		return result
	}
	
	/// Shold be called from `updateRowItems`  only to preserve correct state updates.
	func lazilyLoadedIndex(_ map: WordFrequencyMap, _ key: WordFrequencySortingKey) async -> IndexTable {
		if let cachedTable = indexTablesCache[key] { return cachedTable }
		
		state.send(.buildingIndex)
		let result = await indexBuilder.build(map, index: key)
		indexTablesCache[key] = result
		return result
	}
	
	/// Shold be called from `updateRowItems`  only to preserve correct state updates.
	func buildRowItems(map: WordFrequencyMap, indexTable: IndexTable) throws -> [Item] {
		self.state.send(.updatingRows)
		return try indexTable.map { word in
			guard let frequency = map[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
			return Item(word: word, frequency: frequency)
		}
	}
	
	func executeQueuedRequestIfNeeded() {
		var clearCacheRequested = false
		switch queuedRequest {
		case .none:
			return
		case .clearingCache:
			clearCacheRequested = true
			fallthrough
		case .usingExistedCache:
			queuedRequest = .none
			requestRowsUpdate(overwriteCurrentTask: false, clearCache: clearCacheRequested)
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
	
	func sendSortingKeyChangedEvent(
		from: WordFrequencySortingKey,
		to: WordFrequencySortingKey
	) {
		analytics?.event("indexKeyChaged", context: [
			"from": from,
			"to": to,
			"screen": screenName])
	}
}

