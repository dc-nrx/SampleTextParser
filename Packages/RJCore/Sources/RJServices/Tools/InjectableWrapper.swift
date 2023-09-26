//
//  File.swift
//  
//
//  Created by Dmytro Chapovskyi on 25.09.2023.
//

import Foundation

/**
 A property wrapper that ensures a property can be set only once and only if it's nil.
 
 This property wrapper is designed for dependency injection scenarios
 where the dependency cannot be passed through the initializer. In such cases,
 `@Injected` ensures that once the dependency is provided, it cannot be
 accidentally overwritten or reassigned.
 
 ````
 class ViewModel {
 @Injectable var service: SomeService!
 }

 let viewModel = ViewModel()
 viewModel.service = SomeServiceImpl() // This sets the service dependency.
 viewModel.service = AnotherServiceImpl() // This has no effect as the service is already set.
 ````
 
 - Note: Attempts to access the property before it has been set will result in a fatal error. Attempts to overwrite the injected value will be ignored.
 */
@propertyWrapper
public struct Injected<T> {
   private var value: T?

   public var wrappedValue: T {
	   get {
		   guard let currentValue = value else {
			   fatalError("Attempted to access an uninitialized @Injected property.")
		   }
		   return currentValue
	   }
	   
	   set {
		   guard value == nil else {
			   return
		   }
		   value = newValue
	   }
   }

   public init() {
	   self.value = nil
   }
}
