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
		let res = try await sut.countWords(SampleString.wordsWithApostrophes.rawValue,
										   matchPattern: .alphanumericWithDashesAndApostrophes,
										   wordPostProcessor: CommonWordPostProcessors.endingsExtractor)
		
		XCTAssertEqual(res["it's"], 1)
		XCTAssertEqual(res["they"], 1)
		XCTAssertEqual(res["are"], 1)
		
		XCTAssertNil(res["they're"])
	}

	func testPostProcess_apostropheOmitter() async throws {
		let res = try await sut.countWords(SampleString.wordsWithApostrophes.rawValue,
										   matchPattern: .alphanumericWithDashesAndApostrophes,
										   wordPostProcessor: CommonWordPostProcessors.postApostropheOmitter)
		
		XCTAssertEqual(res["it"], 1)
		XCTAssertEqual(res["they"], 1)
		
		XCTAssertNil(res["is"])
		XCTAssertNil(res["are"])
		XCTAssertNil(res["it's"])
		XCTAssertNil(res["they're"])
	}

}
