import Foundation
import OSLog

import RJServices

open class StandardWordsCounter: WordsCounter {
	
	private let logger = Logger(subsystem: "RJImplementations", category: "StandardWordsCounter")
	
	public init() { }
	
	open func countWords(
		_ string: String,
		config: WordsCounterConfiguration
	) async throws -> WordFrequencyMap {
		return try await withCheckedThrowingContinuation { continuation in
			Task {
				let result = try syncCountWords(string, config: config)
				continuation.resume(returning: result)
			}
		}
	}
	
	private func syncCountWords(
		_ string: String,
		config: WordsCounterConfiguration
	) throws -> WordFrequencyMap {
		logger.debug("Count started for \(string.prefix(16))...; matchPattern = \(config.pattern.rawValue)")
		
		var result = WordFrequencyMap()
		
		// Using NSString for performace considerations related to ranges.
		// (see `testParsingPerformance_400kLines` for measurements)
		let nsString = string as NSString
		let allStringRange = NSRange(location: 0, length: nsString.length)
		
		for match in config.pattern.regex.matches(in: string, range: allStringRange) {
			let word = nsString.substring(with: match.range)
			try processWord(word, config: config, storeIn: &result)
		}
		logger.debug("Finishing count of \(string.prefix(16))...")
		return result
	}

	private func processWord(
		_ word: String,
		config: WordsCounterConfiguration,
		storeIn result: inout WordFrequencyMap
	) throws {
		if let postProcessor = config.postProcessor,
		   let wordsAfterSplit = try postProcessor(String(word)) {
			logger.info("Post-processing: \(word) -> \(wordsAfterSplit)")
			for subWord in wordsAfterSplit {
				result[subWord.lowercased(), default: 0] += 1
			}
		} else {
			result[word.lowercased(), default: 0] += 1
		}
	}

}
