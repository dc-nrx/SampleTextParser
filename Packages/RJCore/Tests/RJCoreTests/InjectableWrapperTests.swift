//
//  InjectableWrapperTests.swift
//  
//
//  Created by Dmytro Chapovskyi on 25.09.2023.
//

import XCTest
import RJServices

final class InjectableWrapperTests: XCTestCase {

	struct Dummy {
		@Injected var value: Int?
	}

	func testInitialValueIsNil() {
		let dummy = Dummy()
		XCTAssertNil(dummy.value)
	}

	func testValueCanBeInjectedOnce() {
		var dummy = Dummy()
		dummy.value = 10
		XCTAssertEqual(dummy.value, 10)
	}

	func testValueCannotBeInjectedTwice() {
		var dummy = Dummy()
		dummy.value = 10
		dummy.value = 20
		XCTAssertEqual(dummy.value, 10)
	}

	func testReassignmentToNilDoesNotChangeValue() {
		var dummy = Dummy()
		dummy.value = 10
		dummy.value = nil
		XCTAssertNotNil(dummy.value)
		XCTAssertEqual(dummy.value, 10)
	}

}
