//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import Foundation

public typealias EventInfo = [String: Any]

public protocol Analytics {
	func error(_ error: Error)
	func event(_ key: String, info: EventInfo)
}
