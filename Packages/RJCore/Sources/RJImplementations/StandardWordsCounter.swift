import Foundation
import OSLog

import RJServices

open class StandardWordsCounter: WordsCounter {
	
	private let logger = Logger(subsystem: "RJImplementations", category: "StandardWordsCounter")
	
	public init() { }
	
	//TODO: Optimize from o(n^2) to o(n)
	open func countWords(
		_ string: String,
		matchPattern: MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> WordFrequencyMap {
		logger.debug("Count started for \(string.prefix(16))...")
		var result = WordFrequencyMap()
		let allStringRange = NSRange(string.startIndex..., in: string)
		for match in matchPattern.regex.matches(in: string, range: allStringRange) {
			let range = Range(match.range, in: string)! // the reason for o(n^2)
			let word = string[range]
			if let postProcessor = wordPostProcessor,
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
