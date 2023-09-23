//
//  WordFrequencyIndexBuilderTests.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import XCTest
import RJServices
import RJImplementations

final class WordFrequencyIndexBuilderTests: XCTestCase {

	var wordsCounter: WordsCounter!
	var sut: WordFrequencyIndexBuilder!
	
    override func setUpWithError() throws {
		wordsCounter = StandardWordsCounter()
        sut = StandardIndexBuilder()
    }

    override func tearDownWithError() throws {
		wordsCounter = nil
        sut = nil
    }

    func testFrequencyIndex() async throws {
		let frequencyMap = try await wordsCounter.countWords(SampleString.simpleEngLowercased.rawValue, config: .init(.alphanumeric))
		let idx = await sut.build(frequencyMap, index: .mostFrequent)
		XCTAssertEqual(idx.first, "two")
    }

	func testAlphabeticalIndex() async throws {
		let frequencyMap = try await wordsCounter.countWords(SampleString.simpleEngLowercased.rawValue, config: .init(.alphanumeric))
		let idx = await sut.build(frequencyMap, index: .alphabetical)
		XCTAssertEqual(idx[0], "one")
		XCTAssertEqual(idx[1], "three")
	}
}
