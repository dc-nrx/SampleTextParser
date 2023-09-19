import Foundation
import RJCore

open class StandardWordsCounter: WordsCounter {
	
	public init() { }
	
	//TODO: Optimize from o(n^2) to o(n)
	open func countWords(
		_ string: String,
		matchPattern: MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> WordFrequencyMap {
		var result = WordFrequencyMap()
		let allStringRange = NSRange(string.startIndex..., in: string)
		for match in matchPattern.regex.matches(in: string, range: allStringRange) {
			let range = Range(match.range, in: string)! // the reason for o(n^2)
			let word = string[range]
			if let postProcessor = wordPostProcessor,
			   let wordsAfterSplit = try postProcessor(String(word)) {
				for subWord in wordsAfterSplit {
					result[subWord.lowercased(), default: 0] += 1
				}
			} else {
				result[word.lowercased(), default: 0] += 1
			}
		}
		
		return result
	}
	
}
