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

public typealias WordFrequencyMap = [String: UInt]
//TODO: Add max capacity associated type? (seems to be a bit too much)
public protocol WordsCounter {
	
	/**
	 Count words in the string.
	 */
	func countWords(
		_ string: String,
		matchPattern: MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> WordFrequencyMap
}


public extension WordsCounter {
	
	func countWords(
		_ string: String,
		matchPattern: MatchPattern
	) async throws -> WordFrequencyMap {
		try await countWords(string, matchPattern: matchPattern, wordPostProcessor: nil)
	}
	
	func countWords(
		textData: Data,
		encoding: String.Encoding = .isoLatin1,
		matchPattern: MatchPattern = .alphanumeric,
		wordPostProcessor: WordPostProcessor? = nil
	) async throws -> WordFrequencyMap {
		//TODO: Use async version
		guard let string = String(data: textData, encoding: encoding) else {
			throw TextParserError.parseFailed
		}
		
		return try await countWords(string, matchPattern: matchPattern, wordPostProcessor: wordPostProcessor)
	}
	
}
