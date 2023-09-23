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
	
	public typealias FileTextProviderFactory = (String, String.Encoding) -> TextProvider
	
	private let wordsCounter: WordsCounter
	private let indexBuilder: WordFrequencyIndexBuilder
	private let analytics: Analytics?
	
	private let fileTextProviderFactory: FileTextProviderFactory
	
	public init(
		wordsCounter: WordsCounter,
		indexBuilder: WordFrequencyIndexBuilder,
		fileTextProviderFactory: @escaping FileTextProviderFactory,
		analytics: Analytics?
	) {
		self.wordsCounter = wordsCounter
		self.indexBuilder = indexBuilder
		self.fileTextProviderFactory = fileTextProviderFactory
		self.analytics = analytics
	}
}

public extension DependencyContainer {
	
	func makeWordsFrequencyVM(
		_ filepath: String,
		encoding: String.Encoding = .utf8,
		configuration: WordsCounterConfiguration = .init(.alphanumericWithDashesAndApostrophes)
	) -> WordsFrequencyVM {
		let textProvider = fileTextProviderFactory(filepath, encoding)
		return WordsFrequencyVM(textProvider, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics, configuration: configuration)
	}
}
