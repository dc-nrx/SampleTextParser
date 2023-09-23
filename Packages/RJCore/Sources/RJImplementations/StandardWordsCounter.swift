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
	
	//TODO: Optimize from o(n^2) to o(n)
	private func syncCountWords(
		_ string: String,
		config: WordsCounterConfiguration
	) throws -> WordFrequencyMap {
		logger.debug("Count started for \(string.prefix(16))...; matchPattern = \(config.pattern.rawValue)")
		
		var result = WordFrequencyMap()
		let allStringRange = NSRange(string.startIndex..., in: string)
		for match in config.pattern.regex.matches(in: string, range: allStringRange) {
			let range = Range(match.range, in: string)! // the reason for o(n^2)
			let word = string[range]
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
		logger.debug("Finishing count of \(string.prefix(16))...")
		return result
	}
}
