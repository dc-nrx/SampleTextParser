//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import Foundation
import OSLog

import RJServices

open class StandardIndexBuilder: WordFrequencyIndexBuilder {

	private let logger = Logger(subsystem: "RJImplementations", category: "StandardIndexBuilder")
	
	public init() { }
	
	open func build(
		_ frequencyMap: WordFrequencyMap,
		index: WordFrequencyIndexKey
	) async -> [WordFrequencyMap.Key] {
		logger.debug("Start building `\(index.rawValue)` index...")
		defer { logger.debug("Building `\(index.rawValue)` index finished.") }
		
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
