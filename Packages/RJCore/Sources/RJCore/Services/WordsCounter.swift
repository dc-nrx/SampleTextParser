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

/**
 A rule to define what should be considered as single `word`.
 
 In case of need, words can be split further after applying the initial pattern matching (see `WordPostProcessor`).
 */
public enum MatchPattern {
	
	/// "1+" alphabetical characters (numbers excluded) separeted by anything else
	case alphanumeric
	
	/// "1+" alphanumeric characters separeted by anything else
	case alphabetical
	
	/**
	 "1+" alphabetical characters, plus `'` and `-`, separeted by anything else.
	 
	 Good to handle words like "mother-in-law" ans "it's". For the latter, it may be useful to split it during the
	 post-processing phase (see `WordPostProcessor`).
	 */
	case alphabeticWithDashesAndApostrophes
	
	// Extend with emoji containing words or whatever else
	// ...
}

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
