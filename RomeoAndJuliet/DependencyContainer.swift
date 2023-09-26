//
//  DependencyContainer.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 23.09.2023.
//

import Foundation

import RJServices
import RJViewModel
import UIKit

/**
 This class serves as a factory for view controllers used throughout the app.
 */
public final class DependencyContainer {
	
	/// Required to keep the `DependencyContainer` agnostic about `TextProvider` implementation.
	public typealias FileTextProviderFactory = (_ path: String, String.Encoding) -> TextProvider
	
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

extension DependencyContainer {
	
	func makeWordsFrequencyVC(
		filepath: String,
		encoding: String.Encoding = .utf8,
		configuration: WordsCounterConfiguration = .init(.alphanumericWithDashesAndApostrophes)
	) -> WordsFrequencyVC {
		let textProvider = fileTextProviderFactory(filepath, encoding)
		let result = UIStoryboard(name: "WordsFrequencyVC", bundle: nil).instantiateInitialViewController() as! WordsFrequencyVC
		result.vm = WordsFrequencyVM(textProvider, wordCounter: wordsCounter, indexBuilder: indexBuilder, analytics: analytics, configuration: configuration)
		return result
	}
	
}
