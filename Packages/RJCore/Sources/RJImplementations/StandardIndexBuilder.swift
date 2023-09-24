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
		index: WordFrequencySortingKey
	) async -> [WordFrequencyMap.Key] {
		return await withCheckedContinuation { continuation in
			logger.debug("Start building `\(index.rawValue)` index...")
			defer { logger.debug("Building `\(index.rawValue)` index finished.") }
			
			let result: [WordFrequencyMap.Key]
			switch index {
			case .alphabetical:
				result = frequencyMap.keys.sorted(by: <)
			case .mostFrequent:
				result = frequencyMap
					.sorted { $0.value > $1.value }
					.map { $0.key }
			case .wordLength:
				result = frequencyMap.keys.sorted { $0.count < $1.count }
			}
			continuation.resume(returning: result)
		}
	}
	
}
