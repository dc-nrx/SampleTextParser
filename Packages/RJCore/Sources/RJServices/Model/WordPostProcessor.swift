//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

/**
 A closure that provides additional processing on words, potentially splitting or modifying them based on specific rules.
 
 For example, it can be used to split contractions like "it's" into ["it", "is"]. Additionally, it can also be used to skip certain words by returning an empty array. If no processing is required, return `nil`.

 - Parameter word: The word that requires post-processing.
 - Returns: An array of post-processed words or `nil` if no action is needed.
 */
public typealias WordPostProcessor = (String) throws -> [String]?

/**
 Provides commonly used post-processing functions for words.
 */
public final class CommonWordPostProcessors {
	
	/**
	 A post-processor that extracts endings from contractions and returns the decomposed words.
	 
	 Note: More complex rules such as "t": "not" (those involving preceding word processing) are omitted here.
	 
	 - Returns: An array of decomposed words or `nil` if no action is needed.
	 */
	public static var endingsExtractor: WordPostProcessor = { word in
		let endingsMap = [
			"re": "are",
			"ve": "have",
			"ll": "will",
			"d": "would"
		]
		
		var subWords = word.components(separatedBy: apostrophesCharacterSet).map { String($0) }
		guard subWords.count == 2,
		   let replacement = endingsMap[subWords[1]] else {
			   return nil
		}
		subWords[1] = replacement
		return subWords
	}

	/**
	 A post-processor that omits any characters after an apostrophe in a word.
	 
	 - Returns: An array containing the word portion before the apostrophe, or `nil` if no action is needed.
	 */
	public static var postApostropheOmitter: WordPostProcessor = { word in
		var subWords = word.components(separatedBy: apostrophesCharacterSet).map { String($0) }
		guard subWords.count == 2, !subWords[0].isEmpty else {
			return nil
		}
		return [subWords[0]]
	}
	
	// MARK: -
	
	/// A character set representing apostrophes for use in the post-processors.
	private static let apostrophesCharacterSet = CharacterSet(charactersIn: MatchPattern.apostrophes)
}
