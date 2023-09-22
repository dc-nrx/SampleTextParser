//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

/**
 Used to split the words further according to some specific rules. (e.g. "it's" -> ["it", "is"].
 Also can be used to skip certain word by returning an empty array.
 
 Return nil if no action required.
 */
public typealias WordPostProcessor = (String) throws -> [String]?

public final class CommonWordPostProcessors {
	
	public static var endingsExtractor: WordPostProcessor = { word in
		/// More complex rules such as "t": "not" (e. g. those involving preceding word processing) are omited here.
		let endingsMap = [
			"re": "are",
			"ve": "have",
			"ll": "will",
			"d": "would"
		]
				
		var subWords = word.split(separator: "'").map { String($0) }
		guard subWords.count == 2,
		   let replacement = endingsMap[subWords[1]] else {
			   return nil
		}
		subWords[1] = replacement
		return subWords
	}

	//TODO: Test
	public static var postApostropheOmitter: WordPostProcessor = { word in
		var subWords = word.split(separator: "'").map { String($0) }
		guard subWords.count == 2 else {
			return nil
		}
		return [subWords[0]]
	}
}
