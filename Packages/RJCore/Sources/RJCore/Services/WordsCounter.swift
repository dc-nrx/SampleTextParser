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

/**
 Used to split the words further according to some specific rules. (e.g. "it's" -> ["it", "is"].
 
 Return nil if no action required.
 */
public typealias WordPostProcessor = (String) throws -> [String]?

//TODO: Add max capacity associated type? (seems to be a bit too much)
public protocol WordsCounter {
	
	/**
	 Count words in the string.
	 */
	func countWords(
		_ string: String,
		matchPattern: MatchPattern,
		wordPostProcessor: WordPostProcessor?
	) async throws -> [String: UInt]
}


public extension WordsCounter {
	
	func countWords(
		_ string: String,
		matchPattern: MatchPattern
	) async throws -> [String : UInt] {
		try await countWords(string, matchPattern: matchPattern, wordPostProcessor: nil)
	}
	
	func countWords(
		textData: Data,
		encoding: String.Encoding = .utf8,
		matchPattern: MatchPattern = .alphanumeric,
		wordPostProcessor: WordPostProcessor? = nil
	) async throws -> [String: UInt] {
		//TODO: Use async version
		guard let string = String(data: textData, encoding: encoding) else {
			throw TextParserError.parseFailed
		}
		
		return try await countWords(string, matchPattern: matchPattern, wordPostProcessor: wordPostProcessor)
	}
	
}
