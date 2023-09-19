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

/// A rule to define what should be considered as `word`.
public enum MatchPattern {
	
	/// 1+ Alphabetical characters (numbers excluded) separeted by anything else
	case alphanumeric
	/// 1+ Alphanumeric characters separeted by anything else
	case alphabetical
	
	// Extend with emoji containing words or whatever else
}

//TODO: Add max capacity associated type? (seems to be a bit too much)
public protocol WordCounter {
	
	/**
	 Count words in the string.
	 */
	func countWords(
		_ string: String,
		matchPattern: MatchPattern
	) async throws -> [String: UInt]
}


public extension WordCounter {
	
	func countWords(
		textData: Data,
		encoding: String.Encoding = .utf8,
		matchPattern: MatchPattern = .alphanumeric
	) async throws -> [String: UInt] {
		//TODO: Use async version
		guard let string = String(data: textData, encoding: encoding) else {
			throw TextParserError.parseFailed
		}
		
		return try await countWords(string, matchPattern: matchPattern)
	}
	
}
