//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import RJServices
import Foundation

class AnalyticsMock: Analytics {
	
	var reportedErrors = [(any Error)]()
	var reportedEvents = [(key: String, context: AnalyticsContext?)]()
	
	func error(_ error: Error) {
		reportedErrors.append(error)
	}
	
	func event(_ key: String, context: AnalyticsContext?) {
		reportedEvents.append((key: key, context: context))
	}
	
}
