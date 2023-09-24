//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 23.09.2023.
//

import Foundation

/**
 Represents an entity capable of providing text content.

 Given that retrieving text, especially from external sources like files, can be
 computationally intensive or I/O bound, this protocol ensures that the text retrieval
 is performed in an asynchronous manner to prevent blocking the main thread
 and ensure responsive user experience.

 Conformers of this protocol can be sources like files, network requests, or even
 simple string literals.
 */
public protocol TextProvider {
	
	/**
	 Asynchronously retrieves text content.
	 
	 Implementations should ensure this operation is non-blocking,
	 especially if the source is I/O-bound like a file or a network request.
	 
	 - Returns: A string containing the text content.
	 - Throws: An error if text retrieval fails.
	 */
	var text: String { get async throws }
}

extension String: TextProvider {
	
	/// For `String` type, the text content is simply the string itself.
	public var text: String { self }
}
