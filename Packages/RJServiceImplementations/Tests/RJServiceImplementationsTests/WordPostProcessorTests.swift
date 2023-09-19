//
//  WordPostProcessorTests.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import XCTest
import RJCore
import RJServiceImplementations

final class WordPostProcessorTests: XCTestCase {

	var sut: (any WordsCounter)!
	
	override func setUp() async throws {
		sut = StandardWordsCounter()
	}
	
	override func tearDown() async throws {
		sut = nil
	}

    func testPostProcess_alwaysReturnNil_makesNoChange() async throws {
		let res = try await sut.countWords(SampleString.hyphenatedWords.rawValue, matchPattern: .alphanumericWithDashesAndApostrophes) { word in
			return nil
		}
		XCTAssertEqual(res["mother-in-law"], 1)
		XCTAssertEqual(res["father-in-law"], 1)
	}

	func testPostProcess_splitWordsWithSingleApostrophe() async throws {
		
		/// More complex rules such as "t": "not" (which also involve preceding word processing) are omited here.
		let endingsMap = [
			"s": "is",
			"re": "are",
			"ve": "have",
			"ll": "will",
			"d": "would"
		]
		
		let res = try await sut.countWords(SampleString.wordsWithApostrophes.rawValue,
										   matchPattern: .alphanumericWithDashesAndApostrophes,
										   wordPostProcessor: CommonWordPostProcessors.endingsExtractor)
		
		XCTAssertEqual(res["it"], 1)
		XCTAssertEqual(res["is"], 1)
		XCTAssertEqual(res["they"], 1)
		XCTAssertEqual(res["are"], 1)
		
		XCTAssertNil(res["it's"])
		XCTAssertNil(res["they're"])
	}

}
