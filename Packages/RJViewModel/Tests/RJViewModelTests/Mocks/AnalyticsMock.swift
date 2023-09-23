//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import RJServices
import Foundation

class AnalyticsMock: Analytics {
	
	var lastReportedError: (any Error)?
	var lastReportedEvent: (key: String, context: AnalyticsContext?)?
	
	func error(_ error: Error) {
		lastReportedError = error
	}
	
	func event(_ key: String, context: AnalyticsContext?) {
		lastReportedEvent = (key: key, context: context)
	}
	
}
