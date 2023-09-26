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
		sut.onAppear()
		await waitUntil(sut, in: .finished)
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
		
		sut.onIndexKeyChanged(.alphabetical)
		await waitUntil(sut, in: .finished)

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
		
		await waitUntil(sut, in: .buildingIndex)
		self.sut.onIndexKeyChanged(.alphabetical)
		
		await waitUntil(sut, in: .finished)
		await waitUntil(sut, in: .finished)
				
		XCTAssertEqual(sut.rowItems.value.first!.word, "aaa")
	}

	// TODO: implement bunch of tests for error reporting and recovery from them

}

private extension RJViewModelTests {

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
	
	func waitUntil(_ vm: WordsFrequencyVM, in state: WordsFrequencyVM.State) async {
		await withCheckedContinuation { continuation in
			vm.state
				.filter { $0 == state }
				.first()
				.sink { _ in continuation.resume() }
				.store(in: &cancellables)
		}
	}
}
