//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation
import RJCore

//TODO: Add RJServiceImplementations as second target to RJCore
open class StandardIndexBuilder: WordFrequencyIndexBuilder {
	
	public init() { }
	
	open func build(
		_ frequencyMap: WordFrequencyMap,
		index: WordFrequencyIndexKey
	) async -> [WordFrequencyMap.Key] {
		switch index {
		case .alphabetical:
			return frequencyMap.keys
				.sorted(by: <)
		case .mostFrequent:
			return frequencyMap
				.sorted { $0.value > $1.value }
				.map { $0.key }
		}
	}
	
}
