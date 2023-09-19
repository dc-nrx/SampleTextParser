//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation

public enum WordFrequencyIndexKey {
	case alphabetical
	case mostFrequent
}

public protocol WordFrequencyIndexBuilder where WordFrequencyMap.Key: Comparable {
	
	/// Return all words sorted according to provided rules.
	func build(
		_ frequencyMap: WordFrequencyMap,
		index: WordFrequencyIndexKey
	) -> [WordFrequencyMap.Key]
	
}
