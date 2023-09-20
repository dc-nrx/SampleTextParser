import XCTest
import RJCore
import RJServiceImplementations
import Combine
@testable import RJViewModel

final class RJViewModelTests: XCTestCase {
	
	var cancellables: Set<AnyCancellable>!
	
	let samples = [
		"abc abc abc aaa ddd"
	]

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
	
	func testOnIndexKeyChanged() {
		let sut = makeSut(samples[0])
		
		sut.onIndexKeyChanged(.mostFrequent)
		XCTAssertEqual(sut.indexKey, .mostFrequent)
		
		sut.onIndexKeyChanged(.alphabetical)
		XCTAssertEqual(sut.indexKey, .alphabetical)
	}
	
	func testRegularFlow_stateChanges() async {
		let sut = makeSut(samples[0])
		let exp = expectation(description: "All expected states in right order after onAppear call")
		var states = [WordsFrequencyVM.State]()
		sut.state.sink { state in
			states.append(state)
			if states == [.initial, .updateStarted, .countingWords, .buildingIndex, .updatingRows, .finished] {
				exp.fulfill()
			}
		}
		.store(in: &cancellables)
		
		sut.onAppear()
		await fulfillment(of: [exp])
	}
	
	func testIndexChange_afterInitialLoad() async {
		let sut = makeSut(samples[0])
		XCTAssertTrue(sut.rowItems.value.isEmpty)
		
		let exp1 = expectFinishedState(sut)
		sut.onAppear()
		await fulfillment(of: [exp1])
		
		XCTAssertEqual(sut.rowItems.value.map { $0.frequency }, [3, 1, 1])
		
		let exp2 = expectFinishedState(sut)
		sut.onIndexKeyChanged(.alphabetical)
		await fulfillment(of: [exp2])
		
		XCTAssertEqual(sut.rowItems.value.map { $0.word }, ["aaa", "abc", "ddd"])
	}
}

private extension RJViewModelTests {
	
	func makeSut(_ string: String) -> WordsFrequencyVM {
		makeSut(data: string.data(using: .utf8)!)
	}
	
	func makeSut(data: Data) -> WordsFrequencyVM {
		WordsFrequencyVM(data, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics)
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
		includeInitial: Bool = true
	) -> XCTestExpectation {
		let exp = expectation(description: "All expected states in right order after onAppear call")
		var expectedSequence: [WordsFrequencyVM.State] = includeInitial ? [.initial] : []
		expectedSequence.append(contentsOf: [.initial, .updateStarted, .countingWords, .buildingIndex, .updatingRows, .finished])
		
		var states = [WordsFrequencyVM.State]()
		sut.state
			.collect(expectedSequence.count)
			.filter { $0 == expectedSequence }
			.first() // avoid accidental re-fulfillment of the `exp` in non-atomic tests
			.sink { _ in exp.fulfill() }
			.store(in: &cancellables)
		return exp
	}
}
