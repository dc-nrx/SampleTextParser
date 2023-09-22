import XCTest
import RJCore
@testable import RJServiceImplementations

final class RJServiceImplementationsTests: XCTestCase {
	
	var sut: (any WordsCounter)!
	
	override func setUp() async throws {
		sut = StandardWordsCounter()
	}
	
	override func tearDown() async throws {
		sut = nil
	}
	
    func testSimpleEngLowercase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngLowercased.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}
	
	func testSimpleEngMixCase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngMixCase.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}

	func testZeroLength() async throws {
		let res = try await sut.countWords(SampleString.zeroLength.rawValue, matchPattern: .alphanumeric)
		XCTAssertTrue(res.isEmpty)
	}

	func testWhitespaces() async throws {
		let res = try await sut.countWords(SampleString.whitespaces.rawValue, matchPattern: .alphanumeric)
		XCTAssertTrue(res.isEmpty)
	}

	func testSingleEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.singleEmoji.rawValue, matchPattern: .alphanumeric)
		XCTAssertTrue(res.isEmpty) // Assumes your word matching pattern does not count emojis as words.
	}

	func testSameWordSeparatedByEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.sameWordSeparatedByEmoji.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["one"], 2)
	}

	func testDifferentWordsSeparatedByEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.differentWordsSeparatedByEmoji.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 1)
	}

	func testWithSubstringWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.withSubstringWord.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["spy"], 1)
		XCTAssertEqual(res["with"], 1)
		XCTAssertEqual(res["spying"], 1)
		XCTAssertEqual(res["glass"], 1)
	}

	func testUkrainianWithComplexUnicodeCharAndSubstringAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.ukrainianWithComplexUnicodeCharAndSubstring.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["їжа"], 2)
		XCTAssertEqual(res["їжак"], 1)
	}

	func testChineseSimplifiedAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseSimplified.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["食品"], 2)
		XCTAssertEqual(res["刺猬"], 1)
	}
	
	func testChineseEngMixAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseEngMix.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["罗密欧"], 1)
		XCTAssertEqual(res["means"], 1)
		XCTAssertEqual(res["romeo"], 1)
	}

	func testChineseEngMixWithApostropheQuotesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseEngMixWithApostropheQuotes.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["罗密欧"], 1)
		XCTAssertEqual(res["means"], 1)
		XCTAssertEqual(res["romeo"], 1)
	}

	func testSameWordWithAndWithoutApostropheQuotesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.sameWordWithAndWithoutApostropheQuotes.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["romeo"], 2)
		XCTAssertEqual(res["means"], 1)
	}

	func testSimpleArabicLowercasedAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.simpleArabicLowercased.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["واحد"], 1)
		XCTAssertEqual(res["اثنان"], 2)
		XCTAssertEqual(res["ثلاثة"], 1)
	}

	func testSpecialCharacterMixedWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.specialCharacterMixedWord.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["he11o"], 1)
	}

	func testMixedNumbersAndLettersAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.mixedNumbersAndLetters.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["abc123"], 1)
		XCTAssertEqual(res["def456"], 1)
		XCTAssertEqual(res["ghi789"], 1)
	}
	
	func testSpecialCharactersAndWhitespacesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.specialCharactersAndWhitespaces.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}

	func testWordsWithPunctuationsAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsWithPunctuations.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}

	func testEmojiWithinWordsAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.emojiWithinWords.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["love"], 2)
		XCTAssertEqual(res["hate"], 2)
		XCTAssertEqual(res["like"], 1)
	}

	func testMixedLanguagesAndNumbersAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.mixedLanguagesAndNumbers.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["世界"], 1)
		XCTAssertEqual(res["123"], 1)
		XCTAssertEqual(res["bonjour"], 1)
		XCTAssertEqual(res["мир"], 1)
	}

	func testUrlAsWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.urlAsWord.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["https"], 1)
		XCTAssertEqual(res["www"], 1)
		XCTAssertEqual(res["example"], 1)
		XCTAssertEqual(res["com"], 1)
	}
	
	func testHyphenatedWordsAlphanumericWithDashesAndApostrophes() async throws {
		let res = try await sut.countWords(SampleString.hyphenatedWords.rawValue, matchPattern: .alphanumericWithDashesAndApostrophes)
		XCTAssertEqual(res["mother-in-law"], 1)
		XCTAssertEqual(res["father-in-law"], 1)
		
		XCTAssertNil(res["father"])
		XCTAssertNil(res["mother"])
		XCTAssertNil(res["in"])
		XCTAssertNil(res["law"])
		XCTAssertNil(res["-"])
	}

	func testWordsWithApostrophesAlphanumericWithDashesAndApostrophes() async throws {
		let res = try await sut.countWords(SampleString.wordsWithDifferentApostrophes.rawValue, matchPattern: .alphanumericWithDashesAndApostrophes)
		
		XCTAssertEqual(res["we’ll"], 1)
		XCTAssertEqual(res["she's"], 1)
		XCTAssertEqual(res["you`re"], 1)
		
		XCTAssertNil(res["we"])
		XCTAssertNil(res["ll"])
		XCTAssertNil(res["will"])

		XCTAssertNil(res["she"])
		XCTAssertNil(res["is"])
		XCTAssertNil(res["s"])

		XCTAssertNil(res["you"])
		XCTAssertNil(res["are"])
		XCTAssertNil(res["re"])
	}
	
	func testHyphenatedWordsAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.hyphenatedWords.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["mother"], 1)
		XCTAssertEqual(res["father"], 1)
		XCTAssertEqual(res["in"], 2)
		XCTAssertEqual(res["law"], 2)
		
		XCTAssertNil(res["mother-in-law"])
		XCTAssertNil(res["father-in-law"])
	}

	func testWordsWithApostrophesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsWithApostrophes.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["it"], 1)
		XCTAssertEqual(res["s"], 1)
		XCTAssertEqual(res["they"], 1)
		XCTAssertEqual(res["re"], 1)
		
		XCTAssertNil(res["it's"])
		XCTAssertNil(res["they're"])

	}

	func testWordsSeparatedByNewlinesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsSeparatedByNewLine.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}
}
