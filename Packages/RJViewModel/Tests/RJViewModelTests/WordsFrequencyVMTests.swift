import XCTest
import RJCore
import RJServiceImplementations
@testable import RJViewModel

final class RJViewModelTests: XCTestCase {
	
	var wordsCounter: WordsCounter { StandardWordsCounter() }
	var indexBuilder: WordFrequencyIndexBuilder { StandardIndexBuilder() }
	var analytics: Analytics { AnalyticsMock() }
	
	let samples = [
		"abc abc abc aaa ddd"
	]
	
	func testOnIndexKeyChanged() {
		let sut = makeSut(samples[0])
		
		sut.onIndexKeyChanged(.mostFrequent)
		XCTAssertEqual(sut.indexKey, .mostFrequent)
		
		sut.onIndexKeyChanged(.alphabetical)
		XCTAssertEqual(sut.indexKey, .alphabetical)
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
