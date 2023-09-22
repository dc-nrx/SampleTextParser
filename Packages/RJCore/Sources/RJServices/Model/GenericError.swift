//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import Foundation

public enum GenericError: Error {
	case unexpectedNil(file: String, line: Int)
}
