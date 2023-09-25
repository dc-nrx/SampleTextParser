//
//  File.swift
//
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

/**
 Defines patterns for matching words within a text.
 
 This enum provides rules that specify what constitutes a single word.
 Depending on the rule chosen, it determines how words are identified
 and extracted from a given text. For further refinement or processing of words
 after the initial pattern matching, consider using `WordPostProcessor`.
 */
public enum MatchPattern {
	
	/// Matches sequences of one or more alphanumeric characters.
	case alphanumeric
	
	/**
	 Matches sequences of one or more alphabetical characters,
	 possibly interspersed with apostrophes (see `apostrophes` below) and dashes (`-`).
	 
	 This pattern is useful for identifying compound words like "mother-in-law"
	 and contractions like "it's". For contractions, consider further processing
	 using `WordPostProcessor` to split them into their component words.
	 */
	case alphanumericWithDashesAndApostrophes
	
	// Placeholder for future patterns, such as those matching words containing emojis.
	// ...
	
	/// A string containing various apostrophe characters.
	public static let apostrophes = "’'`"
}

public extension MatchPattern {
	
	/**
	 Returns a `NSRegularExpression` object corresponding to the match pattern.
	 
	 Uses `NSRegularExpression` for compatibility with versions prior
	 to iOS 16, even though the newer `Regex` type might be preferred in later versions.
	 */
	var regex: NSRegularExpression {
		let wordPattern: String
		switch self {
		case .alphanumeric:
			wordPattern = "[\\p{L}\\p{N}]+"
		case .alphanumericWithDashesAndApostrophes:
			wordPattern = "(?<=\\W|^)[\\p{L}\(MatchPattern.apostrophes)-]+(?=\\W|$)"
		}
		return try! NSRegularExpression(pattern: wordPattern, options: [])
	}
}

/// `CaseIterable` conformace for unit testing purposes.
extension MatchPattern: CaseIterable { }
