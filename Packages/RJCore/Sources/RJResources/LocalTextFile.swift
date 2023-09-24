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
	/// About 100k lines
	case romeoAndJuliet_x30 = "RJ_x30"
	/// About 400k lines
	case romeoAndJuliet_x120 = "RJ_x120"
	/// About 1.2m lines
	case romeoAndJuliet_x360 = "RJ_x360"

	public var path: String! {
		Bundle.module.path(forResource: "\(rawValue)", ofType: "txt")
	}
}
