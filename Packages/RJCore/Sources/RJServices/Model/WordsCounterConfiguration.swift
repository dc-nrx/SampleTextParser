//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 24.09.2023.
//

import Foundation

/**
 Configuration settings for the `WordsCounter` to dictate how words should be parsed.
 */
public struct WordsCounterConfiguration {

	/// The pattern used to match words in the text.
	public var pattern: MatchPattern
	
	/// An optional post-processor to manipulate or refine the parsed words.
	public var postProcessor: WordPostProcessor?
	
	/**
	 Initializes a new configuration for word counting.
	 
	 - Parameters:
		- pattern: The pattern used to match words. Defaults to `.alphanumericWithDashesAndApostrophes`.
		- postProcessor: An optional post-processor. Defaults to `nil`.
	 */
	public init(
		_ pattern: MatchPattern = .alphanumericWithDashesAndApostrophes,
		postProcessor: WordPostProcessor? = nil
	) {
		self.pattern = pattern
		self.postProcessor = postProcessor
	}
}
