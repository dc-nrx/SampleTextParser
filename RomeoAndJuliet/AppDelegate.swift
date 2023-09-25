//
//  AppDelegate.swift
//  RomeoAndJuliet
//
//  Created by Dmytro Chapovskyi on 19.09.2023.
//

import UIKit
import RJImplementations
import RJResources

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	static var shared: AppDelegate { UIApplication.shared.delegate as! AppDelegate }
	
	var window: UIWindow?
	
	let dependencyContainer = DependencyContainer(
		wordsCounter: StandardWordsCounter(),
		indexBuilder: StandardIndexBuilder(),
		fileTextProviderFactory: FileTextProvider.init,
		analytics: nil)
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = dependencyContainer.makeWordsFrequencyVC(filepath: LocalTextFile.romeoAndJuliet_x120.path)
		
		return true
	}

}

