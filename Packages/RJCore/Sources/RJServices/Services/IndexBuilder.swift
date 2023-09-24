//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

public enum WordFrequencySortingKey: String, CaseIterable {
	case alphabetical
	case mostFrequent
	case wordLength
}

public protocol WordFrequencyIndexBuilder where WordFrequencyMap.Key: Comparable {
	
	/// Return all words sorted according to provided rules.
	func build(
		_ frequencyMap: WordFrequencyMap,
		index: WordFrequencySortingKey
	) async -> [WordFrequencyMap.Key]
	
}
