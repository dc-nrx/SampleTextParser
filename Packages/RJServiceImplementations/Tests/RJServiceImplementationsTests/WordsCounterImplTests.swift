import XCTest
@testable import RJServiceImplementations

final class RJServiceImplementationsTests: XCTestCase {
	
	var sut: WordsCounterImpl!
	
	override func setUp() async throws {
		sut = WordsCounterImpl()
	}
	
	override func tearDown() async throws {
		sut = nil
	}
	
    func testSimpleEngLowercase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngLowercased.rawValue)
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}
	
	func testSimpleEngMixCase() async throws {
		let res = try await sut.countWords(SampleString.simpleEngMixCase.rawValue)
		XCTAssertEqual(res["one"], 1)
		XCTAssertEqual(res["two"], 2)
		XCTAssertEqual(res["three"], 1)
	}

	func testZeroLength() async throws {
		let res = try await sut.countWords(SampleString.zeroLength.rawValue)
		XCTAssertTrue(res.isEmpty)
	}

	func testWhitespaces() async throws {
		let res = try await sut.countWords(SampleString.whitespaces.rawValue)
		XCTAssertTrue(res.isEmpty)
	}

	func testSingleEmoji() async throws {
		let res = try await sut.countWords(SampleString.singleEmoji.rawValue)
		XCTAssertTrue(res.isEmpty) // Assumes your word matching pattern does not count emojis as words.
	}

	func testSameWordSeparatedByNumberAlphanumeric() async throws {
		let res = try await sut.countWords(SampleString.sameWordSeparatedByNumber.rawValue, matchPattern: .alphanumeric)
		XCTAssertEqual(res["one4one"], 1) // Assumes that "one4one" is counted as a single word by the alphanumeric pattern.
	}

	func testSameWordSeparatedByNumberAlphabetical() async throws {
		let res = try await sut.countWords(SampleString.sameWordSeparatedByNumber.rawValue, matchPattern: .alphabetical)
		XCTAssertEqual(res["one"], 2) // Assumes that "one4one" is counted as a single word by the alphanumeric pattern.
	}

}
