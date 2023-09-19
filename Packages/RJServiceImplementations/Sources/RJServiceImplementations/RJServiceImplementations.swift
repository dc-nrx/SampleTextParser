import RJCore

public final class WordsCounterImpl: WordsCounter {
	
	/// O(n)
	public func countWords(
		_ string: String,
		matchPattern: MatchPattern = .alphabeticWithDashesAndApostrophes,
		wordPostProcessor: WordPostProcessor? = nil
	) async throws -> [String : UInt] {
		var result = [String: UInt]()
		for word in string.components(separatedBy: .alphanumerics.inverted) {
			result[word.lowercased(), default: 0] += 1
		}
		return result
	}
	
}
