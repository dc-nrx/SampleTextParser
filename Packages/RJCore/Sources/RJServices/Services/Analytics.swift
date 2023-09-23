//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import Foundation

public typealias AnalyticsContext = [String: Any]

public protocol Analytics {
	
	var screenShownEventName: String { get }
	var screenNameKey: String { get }
	
	func error(_ error: Error)
	
	func event(_ key: String, context: AnalyticsContext?)
	
	func screen(_ name: String, context: AnalyticsContext?)
}

public extension Analytics {
	
	var screenShownEventName: String { "screenShown" }
	var screenNameKey: String { "screenName" }

	func event(_ key: String) {
		event(key, context: nil)
	}

	func screen(_ name: String, context: AnalyticsContext? = nil) {
		var context = context ?? AnalyticsContext()
		context[screenNameKey] = name
		event(screenShownEventName, context: context)
	}
}
