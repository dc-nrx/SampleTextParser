//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

/**
 Represents the different keys or criteria for sorting and indexing word frequencies.
 Analogous to choosing a column to index in a database.
 */
public enum WordFrequencySortingKey: String, CaseIterable {
	case alphabetical
	case mostFrequent
	case wordLength
}

/**
 A protocol to build an index of word frequencies.

 This is similar to creating an index in a database for faster retrieval
 based on certain columns. Here, it defines the requirements for indexing words
 based on certain criteria like alphabetical order, word frequency, or word length.
 */
public protocol WordFrequencyIndexBuilder where WordFrequencyMap.Key: Comparable {
	
	/**
	 Creates an index (or sorted list) of words based on the provided criteria.
	 
	 - Parameters:
	   - frequencyMap: The map of word frequencies to be indexed.
	   - index: The sorting key or criteria to use for indexing.
	 - Returns: An indexed array of words according to the given `index`.
	 */
	func build(
		_ frequencyMap: WordFrequencyMap,
		index: WordFrequencySortingKey
	) async -> [WordFrequencyMap.Key]
}
