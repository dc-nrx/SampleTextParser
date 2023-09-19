//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

/**
 A rule to define what should be considered as single `word`.
 
 In case of need, words can be split further after applying the initial pattern matching (see `WordPostProcessor`).
 
 `CaseIterable` conformace for unit testing purposes
 */
public enum MatchPattern: CaseIterable {
	
	/// "1+" alphanumeric characters separeted by anything else
	case alphanumeric
	
	/**
	 "1+" alphabetical characters, plus `'` and `-`, separeted by anything else.
	 
	 Good to handle words like "mother-in-law" ans "it's". For the latter, it may be useful to split it during the
	 post-processing phase (see `WordPostProcessor`).
	 */
	case alphabeticWithDashesAndApostrophes
	
	// Extend with emoji containing words or whatever else
	// ...
}

public extension MatchPattern {
	
	/// Using `NSRegularExpression` instead of the newer `Regex` to support versions prior to iOS 16.
	var regex: NSRegularExpression {
		let wordPattern: String
		switch self {
		case .alphanumeric:
			wordPattern = "[\\p{L}\\p{N}]+"
		case .alphabeticWithDashesAndApostrophes:
			wordPattern = "\\b[\\p{L}'-]+\\b"
		}
		return try! NSRegularExpression(pattern: wordPattern, options: [])
	}
}

