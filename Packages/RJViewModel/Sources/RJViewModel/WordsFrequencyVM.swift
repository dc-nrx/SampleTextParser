
import Foundation
import Combine
import OSLog

import RJServices

public extension WordsFrequencyVM {
	
	enum State: Equatable {
		case initial
		case updateStarted
		case countingWords
		case buildingIndex
		case updatingRows
		case finished
		case cancelling
		case cancelled
		case error(description: String)
	}
	
	typealias Item = (word: WordFrequencyMap.Key, frequency: WordFrequencyMap.Value)
}

public final class WordsFrequencyVM {
	
	// MARK: - Public
	
	public static let screenName = "WordsFrequency"
	
	//TODO: Make var / clear cache on change
	public private(set) var text: String
	public private(set) var configuration: WordsCounterConfiguration
	public private(set) var indexKey: WordFrequencyIndexKey
	
	public private(set) var state = CurrentValueSubject<State, Never>(.initial)
	public private(set) var rowItems = CurrentValueSubject<[Item], Never>([])
		
	// MARK: - Private
	typealias IndexTable = [WordFrequencyMap.Key]
	private var indexTablesCache = [WordFrequencyIndexKey: IndexTable]()
	private var frequencyMapCache: WordFrequencyMap?
	
	private var wordCounter: WordsCounter
	private var indexBuilder: WordFrequencyIndexBuilder
	private var analytics: Analytics?
	
	private var updateTask: Task<Void, Never>? = nil
	private var resetTask: Task<Void, Never>? = nil
	
	private var cancellables = Set<AnyCancellable>()
	private let logger = Logger(subsystem: "RJViewModel", category: "WordsFrequencyVM")
	
	// MARK: - Init
	public init(
		_ text: String,
		wordCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics? = nil,
		configuration: WordsCounterConfiguration = .init(.alphanumericWithDashesAndApostrophes),
		initialIndexKey: WordFrequencyIndexKey = .mostFrequent
	) {
		self.text = text
		self.wordCounter = wordCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
		self.indexKey = initialIndexKey
		self.configuration = configuration
		
		self.setupLogging()
	}

}

// MARK: - Methods
// MARK: - Public
public extension WordsFrequencyVM {
	
	func onAppear() {
		analytics?.screen(WordsFrequencyVM.screenName)
		if state.value == .initial {
			loadData(for: indexKey)
		}
	}
	
	func onIndexKeyChanged(_ newKey: WordFrequencyIndexKey) {
		guard indexKey != newKey else { return }
		
		sendIndexChangedEvent(from: indexKey, to: newKey)
		indexKey = newKey
		loadData(for: indexKey)
	}
	
	func onTextChange(to newText: String) {
		// not checking for `text != newText` to avoid main thread
		// hanging in case of a huge text.
		text = newText
		reloadAfterCacheInvalidation()
	}
	
	func onConfigChange(to newConfig: WordsCounterConfiguration) {
		// Not checkign here as well, since `WordsCounterConfiguration` has a closure parameter,
		// which would be a bit tricky to conform to `Equetable`.
		configuration = newConfig
		reloadAfterCacheInvalidation()
	}
}

// MARK: - Private
private extension WordsFrequencyVM {
	
	// MARK: - Loading data
	
	func loadData(for newKey: WordFrequencyIndexKey) {
		guard updateTask == nil else { return }
		
		state.send(.updateStarted)
		updateTask = Task { [weak self] in
			guard let self else { return }
			
			defer { self.updateTask = nil }
			do {
				let frequencyMap = try await self.lazilyLoadedFrequencyMap()
				guard !Task.isCancelled else { throw CancellationError() }

				let indexTable = await self.lazilyLoadedIndex(frequencyMap, newKey)
				guard !Task.isCancelled else { throw CancellationError() }
				
				self.state.send(.updatingRows)
				let updatedItems = try indexTable.map { word in
					guard let frequency = frequencyMap[word] else { throw GenericError.unexpectedNil(file: #file, line: #line) }
					return Item(word: word, frequency: frequency)
				}
				guard !Task.isCancelled else { throw CancellationError() }

				self.rowItems.send(updatedItems)
				self.state.send(.finished)
			} catch {
				if error is CancellationError {
					state.send(.cancelled)
				} else {
					handle(error: error)
				}
			}
		}
	}
	
	func lazilyLoadedFrequencyMap() async throws -> WordFrequencyMap {
		if let frequencyMapCache { return frequencyMapCache }
		
		state.send(.countingWords)
		let result = try await wordCounter.countWords(text, config: configuration)
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

	// MARK: - Cancellation
	
	func reloadAfterCacheInvalidation() {
		if let resetTask { resetTask.cancel() }
		resetTask = Task { [weak self] in
			guard let self else { return }
			
			defer { self.resetTask = nil }
			await self.invalidateCache()
			
			guard !Task.isCancelled else { return }
			self.loadData(for: self.indexKey)
		}
	}
	
	func invalidateCache() async {
		if let updateTask, state.value != .cancelling {
			state.send(.cancelling)
			updateTask.cancel()
			await waitForCancelledState()
			self.updateTask = nil
		}
		
		clearCache()
		state.send(.initial)
	}
	
	func clearCache() {
		indexTablesCache = [WordFrequencyIndexKey: IndexTable]()
		frequencyMapCache = nil
		rowItems.send([])
	}
	
	func waitForCancelledState() async {
		await withCheckedContinuation { continuation in
			state
				.dropFirst()
				.filter { $0 == .cancelled}
				.first()
				.sink { _ in continuation.resume() }
				.store(in: &cancellables)
		}
	}

	// MARK: - Misc

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
	
	func sendIndexChangedEvent(
		from: WordFrequencyIndexKey,
		to: WordFrequencyIndexKey
	) {
		analytics?.event("indexKeyChaged", context: [
			"from": indexKey,
			"to": to,
			"screen": WordsFrequencyVM.screenName])
	}
}

