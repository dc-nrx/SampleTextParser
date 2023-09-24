//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

/// Represents a map of words and their respective frequencies.
public typealias WordFrequencyMap = [String: UInt]

/**
 A protocol that defines the capability to count word frequencies in a given string.
 */
public protocol WordsCounter {
	
	/**
	 Count the frequencies of words in the given string based on the provided configuration.
	 
	 - Parameters:
		- string: The input text string.
		- config: The configuration detailing how words should be parsed.
	 
	 - Returns: A `WordFrequencyMap` containing word frequencies.
	 */
	func countWords(
		_ string: String,
		config: WordsCounterConfiguration
	) async throws -> WordFrequencyMap
}

public extension WordsCounter {
	
	/**
	 Count the frequencies of words in the given string using the default configuration.
	 
	 - Parameter string: The input text string.
	 
	 - Returns: A `WordFrequencyMap` containing word frequencies.
	 */
	func countWords(
		_ string: String
	) async throws -> WordFrequencyMap {
		try await countWords(string, config: .init())
	}
}
