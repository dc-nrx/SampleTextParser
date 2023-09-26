//
//  AppDelegate.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import UIKit
import OSLog

import RJImplementations
import RJResources

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	private let logger = Logger(subsystem: "dc.RomeoAndJuliet", category: "AppDelegate")
	
	private let dependencyContainer = DependencyContainer(
		wordsCounter: StandardWordsCounter(),
		indexBuilder: StandardIndexBuilder(),
		fileTextProviderFactory: FileTextProvider.init,
		analytics: nil)
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		logger.info("entering \(#function)")
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = dependencyContainer.makeWordsFrequencyVC(filepath: LocalTextFile.romeoAndJuliet_x120.path)
		
		logger.info("returning from \(#function)")
		return true
	}

}

