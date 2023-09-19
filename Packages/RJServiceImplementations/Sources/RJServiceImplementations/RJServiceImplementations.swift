import Foundation
import RJCore

public final class WordsCounterImpl: WordsCounter {
	
	/// O(n)
	public func countWords(
		_ string: String,
		matchPattern: MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> [String : UInt] {
		var result = [String: UInt]()
		let allStringRange = NSRange(string.startIndex..., in: string)
		for match in matchPattern.regex.matches(in: string, range: allStringRange) {
			let range = Range(match.range, in: string)!
			let word = string[range]
			result[word.lowercased(), default: 0] += 1
		}
		return result
	}
	
}
