import XCTest

import RJServices
import RJImplementations
import RJResources

final class WordsCounterImplTests: XCTestCase {
	
	var sut: (any WordsCounter)!
	
	override func setUp() async throws {
		sut = StandardWordsCounter()
	}
	
	override func tearDown() async throws {
		sut = nil
	}
	
    func testSimpleEngLowercase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngLowercased.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}
	
	func testSimpleEngMixCase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngMixCase.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}

	func testZeroLength() async throws {
		let res = try await sut.countWords(SampleString.zeroLength.rawValue, config: .init(.alphanumeric))
		XCTAssertTrue(res.isEmpty)
	}

	func testWhitespaces() async throws {
		let res = try await sut.countWords(SampleString.whitespaces.rawValue, config: .init(.alphanumeric))
		XCTAssertTrue(res.isEmpty)
	}

	func testSingleEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.singleEmoji.rawValue, config: .init(.alphanumeric))
		XCTAssertTrue(res.isEmpty) // Assumes your word matching pattern does not count emojis as words.
	}

	func testSameWordSeparatedByEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.sameWordSeparatedByEmoji.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["one"], 2)
	}

	func testDifferentWordsSeparatedByEmojiAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.differentWordsSeparatedByEmoji.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 1)
	}

	func testWithSubstringWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.withSubstringWord.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["spy"], 1)
		XCTAssertEqual(res["with"], 1)
		XCTAssertEqual(res["spying"], 1)
		XCTAssertEqual(res["glass"], 1)
	}

	func testUkrainianWithComplexUnicodeCharAndSubstringAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.ukrainianWithComplexUnicodeCharAndSubstring.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["їжа"], 2)
		XCTAssertEqual(res["їжак"], 1)
	}

	func testChineseSimplifiedAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseSimplified.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["食品"], 2)
		XCTAssertEqual(res["刺猬"], 1)
	}
	
	func testChineseEngMixAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseEngMix.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["罗密欧"], 1)
		XCTAssertEqual(res["means"], 1)
		XCTAssertEqual(res["romeo"], 1)
	}

	func testChineseEngMixWithApostropheQuotesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.chineseEngMixWithApostropheQuotes.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["罗密欧"], 1)
		XCTAssertEqual(res["means"], 1)
		XCTAssertEqual(res["romeo"], 1)
	}

	func testSameWordWithAndWithoutApostropheQuotesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.sameWordWithAndWithoutApostropheQuotes.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["romeo"], 2)
		XCTAssertEqual(res["means"], 1)
	}

	func testSimpleArabicLowercasedAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.simpleArabicLowercased.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["واحد"], 1)
		XCTAssertEqual(res["اثنان"], 2)
		XCTAssertEqual(res["ثلاثة"], 1)
	}

	func testSpecialCharacterMixedWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.specialCharacterMixedWord.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["he11o"], 1)
	}

	func testMixedNumbersAndLettersAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.mixedNumbersAndLetters.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["abc123"], 1)
		XCTAssertEqual(res["def456"], 1)
		XCTAssertEqual(res["ghi789"], 1)
	}
	
	func testSpecialCharactersAndWhitespacesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.specialCharactersAndWhitespaces.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}

	func testWordsWithPunctuationsAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsWithPunctuations.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}

	func testEmojiWithinWordsAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.emojiWithinWords.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["love"], 2)
		XCTAssertEqual(res["hate"], 2)
		XCTAssertEqual(res["like"], 1)
	}

	func testMixedLanguagesAndNumbersAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.mixedLanguagesAndNumbers.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["世界"], 1)
		XCTAssertEqual(res["123"], 1)
		XCTAssertEqual(res["bonjour"], 1)
		XCTAssertEqual(res["мир"], 1)
	}

	func testUrlAsWordAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.urlAsWord.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["https"], 1)
		XCTAssertEqual(res["www"], 1)
		XCTAssertEqual(res["example"], 1)
		XCTAssertEqual(res["com"], 1)
	}
	
	func testHyphenatedWordsAlphanumericWithDashesAndApostrophes() async throws {
		let res = try await sut.countWords(SampleString.hyphenatedWords.rawValue, config: .init(.alphanumericWithDashesAndApostrophes))
		XCTAssertEqual(res["mother-in-law"], 1)
		XCTAssertEqual(res["father-in-law"], 1)
		
		XCTAssertNil(res["father"])
		XCTAssertNil(res["mother"])
		XCTAssertNil(res["in"])
		XCTAssertNil(res["law"])
		XCTAssertNil(res["-"])
	}

	func testWordsWithApostrophesAlphanumericWithDashesAndApostrophes() async throws {
		let res = try await sut.countWords(SampleString.wordsWithDifferentApostrophes.rawValue, config: .init(.alphanumericWithDashesAndApostrophes))
		
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
		let res = try await sut.countWords(SampleString.hyphenatedWords.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["mother"], 1)
		XCTAssertEqual(res["father"], 1)
		XCTAssertEqual(res["in"], 2)
		XCTAssertEqual(res["law"], 2)
		
		XCTAssertNil(res["mother-in-law"])
		XCTAssertNil(res["father-in-law"])
	}

	func testWordsWithApostrophesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsWithApostrophes.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["it"], 1)
		XCTAssertEqual(res["s"], 1)
		XCTAssertEqual(res["they"], 1)
		XCTAssertEqual(res["re"], 1)
		
		XCTAssertNil(res["it's"])
		XCTAssertNil(res["they're"])

	}

	func testWordsSeparatedByNewlinesAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.wordsSeparatedByNewLine.rawValue, config: .init(.alphanumeric))
		XCTAssertEqual(res["hello"], 1)
		XCTAssertEqual(res["world"], 1)
	}
	
	func testFileProcessing_AlphanumericWithDashesAndApostrophes() async throws {
		let fileString = try String(contentsOfFile: LocalTextFile.romeoAndJuliet.path)
		let res = try await sut.countWords(fileString, config: .init(.alphanumericWithDashesAndApostrophes))
		
		XCTAssertNotNil(res["’tis"])
		XCTAssertNotNil(res["grave-beseeming"])
		XCTAssertNotNil(res["let’s"])
	}
	
	/// Unfortunatelly there is a bug with storing baselines in SPM packages,
	/// hence no proper baseline can be set here.
	///
	/// The test is expected to run under 1 second.
	func testParsingPerformance_100kLines() async throws {
		measure {
			let exp = expectation(description: "Finished")
			Task {
				let fileString = try String(contentsOfFile: LocalTextFile.romeoAndJuliet_x30.path)
				_ = try await sut.countWords(fileString, config: .init(.alphanumericWithDashesAndApostrophes))
				exp.fulfill()
			}
			wait(for: [exp], timeout: 10.0)
		
		}
	}
}
