//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 22.09.2023.
//

import Foundation

// TODO: Case Iterable Tests like in `MatchPattern`
public enum LocalTextFile: String {
	
	case romeoAndJuliet = "Romeo-and-Juliet-fixed"
	
	public var path: String! {
		Bundle.module.path(forResource: "\(rawValue)", ofType: "txt")
	}
}
