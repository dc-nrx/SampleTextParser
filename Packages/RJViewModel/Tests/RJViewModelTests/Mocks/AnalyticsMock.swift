//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import RJCore
import Foundation

class AnalyticsMock: Analytics {
	
	var lastReportedError: (any Error)?
	var lastReportedEvent: (key: String, info: EventInfo)?
	
	func error(_ error: Error) {
		lastReportedError = error
	}
	
	func event(_ key: String, info: EventInfo) {
		lastReportedEvent = (key: key, info: info)
	}
	
}
