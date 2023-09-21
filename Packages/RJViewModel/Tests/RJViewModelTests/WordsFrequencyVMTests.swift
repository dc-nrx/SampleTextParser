import XCTest
import RJCore
import RJServiceImplementations
import Combine
@testable import RJViewModel

final class RJViewModelTests: XCTestCase {
	
	var cancellables: Set<AnyCancellable>!
	var sut: WordsFrequencyVM!
	
	let samples = [
		"abc abc abc aaa ddd"
	]

	let initialStateSequence: [WordsFrequencyVM.State] = [.initial, .updateStarted, .countingWords, .buildingIndex, .updatingRows, .finished]
	let wordsCountedNoIndexStateSequence: [WordsFrequencyVM.State] = [.finished, .updateStarted, .buildingIndex, .updatingRows, .finished]
	let allCachedSequence: [WordsFrequencyVM.State] = [.finished, .updateStarted, .updatingRows, .finished]
	
	var wordsCounter: WordsCounter { StandardWordsCounter() }
	var indexBuilder: WordFrequencyIndexBuilder { StandardIndexBuilder() }
	var analytics: Analytics { AnalyticsMock() }
	
	override func setUp() {
		super.setUp()
		cancellables = []
	}

	override func tearDown() {
		super.tearDown()
		cancellables = nil
	}
	
	func testInititalValues() {
		let sut = makeSut(samples[0])
		XCTAssertTrue(sut.rowItems.value.isEmpty)
		XCTAssertEqual(sut.state.value, .initial)
	}
	
	func testOnIndexKeyChanged() {
		let sut = makeSut(samples[0])
		
		sut.onIndexKeyChanged(.mostFrequent)
		XCTAssertEqual(sut.indexKey, .mostFrequent)
		
		sut.onIndexKeyChanged(.alphabetical)
		XCTAssertEqual(sut.indexKey, .alphabetical)
	}
	
	func testRegularFlow_stateChanges() async {
		let sut = makeSut(samples[0])
		
		let exp1 = expectCorrectStatesSequence(sut, initialStateSequence)
		sut.onAppear()
		await fulfillment(of: [exp1], timeout: 0.1)

		let exp2 = expectCorrectStatesSequence(sut, wordsCountedNoIndexStateSequence)
		sut.onIndexKeyChanged(.alphabetical)
		await fulfillment(of: [exp2], timeout: 0.1)
	}
	
	func testIndexChange_afterInitialLoad() async {
		let sut = makeSut(samples[0])
		
		let exp1 = expectFinishedState(sut)
		sut.onAppear()
		await fulfillment(of: [exp1])
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
		
		let exp2 = expectFinishedState(sut)
		sut.onIndexKeyChanged(.alphabetical)
		await fulfillment(of: [exp2], timeout: 0.1)
		XCTAssertEqual(sut.rowItems.value.map { $0.word }, ["aaa", "abc", "ddd"])
	}
	
	func testMultipleEventCalls_correctStateChanges() async {
		let sut = makeSut(samples[0])
		
		let exp = expectCorrectStatesSequence(sut, initialStateSequence)
		sut.onAppear()
		sut.onAppear()
		sut.onAppear()
		await fulfillment(of: [exp], timeout: 0.1)
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
	}
	
	// TODO: implement bunch of tests for error reporting and recovery from
	func testErrorHandling() async {
		
	}
	
	// TODO: implement tests for data change & mix with error cases
	// TODO: implement & test analytics calls
}

private extension RJViewModelTests {
	
	func makeSut(_ string: String) -> WordsFrequencyVM {
		makeSut(data: string.data(using: .utf8)!)
	}
	
	func makeSut(data: Data) -> WordsFrequencyVM {
		WordsFrequencyVM(data, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics, initialIndexKey: .mostFrequent)
	}

	func expectFinishedState(_ sut: WordsFrequencyVM) -> XCTestExpectation {
		let exp = expectation(description: "`.finished` state should be called")
		sut.state
			.filter { $0 == .finished }
			.first()	// avoid accidental re-fulfillment of the `exp` in non-atomic tests
			.sink { _ in exp.fulfill() }
			.store(in: &cancellables)
		return exp
	}
	
	func expectCorrectStatesSequence(
		_ sut: WordsFrequencyVM,
		_ expectedSequence: [WordsFrequencyVM.State]
	) -> XCTestExpectation {
		let exp = expectation(description: "Expect \(expectedSequence) state sequence")
		sut.state
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
