//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 22.09.2023.
//

import Foundation

public enum TextFile: String {
	
	case romeoAndJuliet = "Romeo-and-Juliet-fixed"
	
	public var path: String! {
		Bundle.module.path(forResource: "\(rawValue)", ofType: "txt")
	}
}
