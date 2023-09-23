//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 23.09.2023.
//

import Foundation
import RJServices

open class FileTextProvider: TextProvider {
	
	open var text: String {
		get async throws {
			try await withCheckedThrowingContinuation { cont in
				Task {
					let result = try String(contentsOfFile: filePath, encoding: encoding)
					cont.resume(returning: result)
				}
			}
		}
	}
		
	open var filePath: String
	open var encoding: String.Encoding
	
	public init(
		_ filePath: String,
		encoding: String.Encoding = .utf8
	) {
		self.filePath = filePath
		self.encoding = encoding
	}
}
