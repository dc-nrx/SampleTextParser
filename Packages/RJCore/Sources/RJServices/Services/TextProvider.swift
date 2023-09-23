//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 23.09.2023.
//

import Foundation

/**
 Since retriving text from a file (or wherever else) is a heavy task,
 this protocol is designed to do it in a properly async way.
 */
public protocol TextProvider {
	
	var text: String { get async throws }
}

