//
//  MatchPatternTests.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import XCTest
@testable import RJCore

final class MatchPatternTests: XCTestCase {
	
	func testAllCases_regexInitializedSuccessfully() throws {
		for pattern in MatchPattern.allCases {
			XCTAssertNotNil(pattern.regex)
		}
    }

}
