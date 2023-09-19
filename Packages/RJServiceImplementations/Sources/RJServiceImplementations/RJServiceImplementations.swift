import RJCore

public final class WordsCounterImpl: WordsCounter {
	
	/// O(n)
	public func countWords(
		_ string: String,
		matchPattern: RJCore.MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> [String : UInt] {
		var result = [String: UInt]()
		for word in string.components(separatedBy: .alphanumerics.inverted) {
			result[word, default: 0] += 1
		}
		return result
	}
	
}
