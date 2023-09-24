//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 20.09.2023.
//

import Foundation

/**
 A generic enumeration to handle common errors that might not be
 specific to any feature or functionality of the application.
 
 This can be particularly useful to capture unforeseen situations
 or exceptional cases that do not fit into other predefined error types.
 */
public enum GenericError: Error {
	
	/**
	 Indicates an unexpected `nil` value was encountered.
	 
	 This error can be used in places where a `nil` value is considered exceptional or unexpected.
	 The `file` and `line` parameters provide context on the location where the error was thrown,
	 which can be useful for debugging.
	 
	 - Parameters:
	   - file: The file in which the error occurred.
	   - line: The line number on which the error occurred.
	 */
	case unexpectedNil(file: String, line: Int)
}
