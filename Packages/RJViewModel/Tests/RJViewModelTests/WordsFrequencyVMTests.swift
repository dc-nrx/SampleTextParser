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
}

private extension RJViewModelTests {
	
	func makeSut(_ string: String) -> WordsFrequencyVM {
		makeSut(data: string.data(using: .utf8)!)
	}
	
	func makeSut(data: Data) -> WordsFrequencyVM {
		WordsFrequencyVM(data, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics)
	}

}
