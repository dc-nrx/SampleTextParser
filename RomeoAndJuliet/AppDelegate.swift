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
		
		let rootVC = UIStoryboard(name: "WordsFrequencyVC", bundle: nil).instantiateInitialViewController() as! WordsFrequencyVC
		rootVC.vm = dependencyContainer.makeWordsFrequencyVM(filepath: LocalTextFile.romeoAndJuliet.path)
		window?.rootViewController = rootVC
		
		return true
	}

}

