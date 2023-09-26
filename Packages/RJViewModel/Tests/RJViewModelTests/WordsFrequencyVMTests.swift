import XCTest
import Combine

import RJServices
import RJImplementations
import RJResources
@testable import RJViewModel

final class RJViewModelTests: XCTestCase {
	
	var cancellables: Set<AnyCancellable>!
	var sut: WordsFrequencyVM!
	var analyticsMock: AnalyticsMock!
	
	let sampleString = "abc abc abc aaa ddd"
	
	let initialUpdateStateSequence: [WordsFrequencyVM.State] = [.updateStarted, .countingWords, .buildingIndex, .updatingRows, .finished]
	let wordsCountedNoIndexStateSequence: [WordsFrequencyVM.State] = [.updateStarted, .buildingIndex, .updatingRows, .finished]
	let everythingCachedSequence: [WordsFrequencyVM.State] = [.updateStarted, .updatingRows, .finished]
	
	var wordsCounter: WordsCounter { StandardWordsCounter() }
	var indexBuilder: WordFrequencyIndexBuilder { StandardIndexBuilder() }
	
	override func setUp() {
		super.setUp()
		cancellables = []
		analyticsMock = AnalyticsMock()
		sut = WordsFrequencyVM(sampleString,
							   wordCounter: StandardWordsCounter(),
							   indexBuilder: StandardIndexBuilder(),
							   analytics: analyticsMock,
							   initialSortingKey: .mostFrequent)
	}
	
	override func tearDown() {
		super.tearDown()
		cancellables = nil
		analyticsMock = nil
		sut = nil
	}
	
	func testInititalValues() {
		XCTAssertTrue(sut.rowItems.value.isEmpty)
		XCTAssertEqual(sut.state.value, .initial)
		
		XCTAssertTrue(analyticsMock.reportedErrors.isEmpty)
		XCTAssertTrue(analyticsMock.reportedEvents.isEmpty)
	}
	
	func testOnIndexKeyChanged() {
		sut.onIndexKeyChanged(.mostFrequent)
		XCTAssertEqual(sut.sortingKey, .mostFrequent)
		
		sut.onIndexKeyChanged(.alphabetical)
		XCTAssertEqual(sut.sortingKey, .alphabetical)
	}
	
	func testRegularFlow_stateChanges() async {
		let exp1 = expectCorrectStatesSequence(sut, initialUpdateStateSequence)
		sut.onAppear()
		await fulfillment(of: [exp1], timeout: 0.1)
		
		let exp2 = expectCorrectStatesSequence(sut, wordsCountedNoIndexStateSequence)
		sut.onIndexKeyChanged(.alphabetical)
		await fulfillment(of: [exp2], timeout: 0.1)
	}
	
	func testIndexChange_afterInitialLoad() async {
		let exp1 = expect(sut, state: .finished)
		sut.onAppear()
		await fulfillment(of: [exp1])
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
		
		let exp2 = expect(sut, state: .finished)
		sut.onIndexKeyChanged(.alphabetical)
		await fulfillment(of: [exp2], timeout: 0.5)
		let res = sut.rowItems.value.map { $0.word }
		XCTAssertEqual(res, ["aaa", "abc", "ddd"])
	}
	
	func testMultipleEventCalls_correctStateChanges() async {
		let exp = expectCorrectStatesSequence(sut, initialUpdateStateSequence)
		sut.onAppear()
		sut.onAppear()
		sut.onAppear()
		await fulfillment(of: [exp], timeout: 0.2)
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
	}
	
	func testAnalytics_singleOnAppear() async {
		sut.onAppear()
		XCTAssertEqual(analyticsMock.reportedEvents.count, 1)
		let event = analyticsMock.reportedEvents[0]
		XCTAssertEqual(event.key, analyticsMock.screenShownEventName)
		
		XCTAssertEqual(event.context?.count, 1)
		let screenName = event.context![analyticsMock.screenNameKey] as! String
		XCTAssertEqual(screenName, sut.screenName)
	}
	
	func testIndexKeyChanged_betweenIndexingAndBuildingRows() async {
		sut.onAppear()
		execute(sut, rightAfter: .buildingIndex) {
			self.sut.onIndexKeyChanged(.alphabetical)
		}
		await fulfillment(of: [expect(sut, state: .finished, dropCurrent: false)])
		await fulfillment(of: [expect(sut, state: .finished, dropCurrent: false)])
				
		XCTAssertEqual(sut.rowItems.value.first!.word, "aaa")
	}

	// TODO: implement bunch of tests for error reporting and recovery from them

}

private extension RJViewModelTests {

	func execute(
		_ sut: WordsFrequencyVM,
		rightAfter state: WordsFrequencyVM.State,
		action: @escaping () -> ()
	) {
		sut.state
			.dropFirst()	// drop the current value
			.filter { $0 == state }
			.first()	// avoid accidental re-fulfillment of the `exp` in non-atomic tests
			.sink { _ in
				action()
			}
			.store(in: &cancellables)
	}
	
	func expect(
		_ sut: WordsFrequencyVM,
		state: WordsFrequencyVM.State,
		dropCurrent: Bool = true
	) -> XCTestExpectation {
		let exp = expectation(description: "`.finished` state should be called")
		sut.state
			.dropFirst(dropCurrent ? 1 : 0)
			.filter { $0 == state }
			.first()	// avoid accidental re-fulfillment of the `exp` in non-atomic tests
			.sink { _ in
				exp.fulfill()
			}
			.store(in: &cancellables)
		return exp
	}
	
	func expectCorrectStatesSequence(
		_ sut: WordsFrequencyVM,
		_ expectedSequence: [WordsFrequencyVM.State]
	) -> XCTestExpectation {
		let exp = expectation(description: "Expect \(expectedSequence) state sequence")
		sut.state
			.dropFirst()	// drop the current value
			.collect(expectedSequence.count)
			.filter { $0 == expectedSequence }
			.first() // avoid accidental re-fulfillment of the `exp` in non-atomic tests
			.sink { _ in exp.fulfill() }
			.store(in: &cancellables)
		return exp
	}
	
	/// A helper function to fix broken tests
	func printStateChanges(_ sut: WordsFrequencyVM) {
		sut.state
			.sink { print("state changed to \($0)") }
			.store(in: &cancellables)
	}
}
