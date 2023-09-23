//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

public enum TextParserError: Error {
	case fileIsEmpty
	case noWordsFound
	case parseFailed
	// Overflows
	case wordTooLong
	case fileTooBig
	//...
}

public struct WordsCounterConfiguration {

	public var pattern: MatchPattern
	public var postProcessor: WordPostProcessor?
	
	public init(
		_ pattern: MatchPattern = .alphanumericWithDashesAndApostrophes,
		postProcessor: WordPostProcessor? = nil
	) {
		self.pattern = pattern
		self.postProcessor = postProcessor
	}

}

public typealias WordFrequencyMap = [String: UInt]

public protocol WordsCounter {
	
	/**
	 Count words in the string.
	 */
	func countWords(
		_ string: String,
		config: WordsCounterConfiguration
	) async throws -> WordFrequencyMap
}


public extension WordsCounter {
	
	func countWords(
		_ string: String
	) async throws -> WordFrequencyMap {
//		let defaultConfig
		try await countWords(string, config: .init())
	}
	
//	func countWords(
//		textData: Data,
//		encoding: String.Encoding = .utf8,
//		matchPattern: MatchPattern = .alphanumeric,
//		wordPostProcessor: WordPostProcessor? = nil
//	) async throws -> WordFrequencyMap {
//		//TODO: Use async version
//		guard let string = String(data: textData, encoding: encoding) else {
//			throw TextParserError.parseFailed
//		}
//		
//		return try await countWords(string, matchPattern: matchPattern, wordPostProcessor: wordPostProcessor)
//	}
	
}
