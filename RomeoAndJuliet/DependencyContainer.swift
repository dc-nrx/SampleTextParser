//
//  DependencyContainer.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 23.09.2023.
//

import Foundation

import RJServices
import RJViewModel

public final class DependencyContainer {
	
	private let wordsCounter: WordsCounter
	private let indexBuilder: WordFrequencyIndexBuilder
	private let analytics: Analytics?
	
	public init(
		wordsCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		analytics: Analytics?
	) {
		self.wordsCounter = wordsCounter
		self.indexBuilder = indexBuilder
		self.analytics = analytics
	}
}

public extension DependencyContainer {
	
	func makeWordsFrequencyVM(
		_ text: String,
		configuration: WordsCounterConfiguration = .init(.alphanumericWithDashesAndApostrophes)
	) -> WordsFrequencyVM {
		WordsFrequencyVM(text, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics, configuration: configuration)
	}
}
