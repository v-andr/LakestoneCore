//
//  ErrorType.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/20/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Throwable Error abstractions and its related types
//

//MARK: - ErrorRepresentable

/// A type that can be carried inside `LakestoneError`
///
/// Any type that conforms to `ErrorRepresentable` can be used as
/// the carried entity that identifiers the LakestoneError instance being thrown
///
/// - note:	`detailMessage` is the string representation (error description) of `ErrorRepresentable` entity,
///			which is required for Java runtime thrown exceptions
/// - warning: avoid using conventional swift way of having error backed by `enum` type
///			if you building with Silver for Java, since at this moment (8.4.96.2041)
///			silver enums are extremely unstable
public protocol ErrorRepresentable: CustomStringConvertible {
	var detailMessage: String { get }
}

extension ErrorRepresentable {
	
	public var description: String {
		return self.detailMessage
	}
}

public func ==(lhs: ErrorRepresentable, rhs: ErrorRepresentable) -> Bool {
	return lhs.detailMessage == rhs.detailMessage
}

//MARK: - StringBackedErrorType

/// Error representable type that is backed by string entity
///
/// This is the most default container to represent simple error types
///	 
///	 //instaniate a simple string-backed error
///	 LakestoneError(StringBackedErrorType("Request is missing"))
///
open class StringBackedErrorType: ErrorRepresentable {
	
	public let representation: String
	public init(_ representation: String) { self.representation = representation }
	
	public var detailMessage: String { return self.representation }
}

#if COOPER
	
extension StringBackedErrorType {
	
	public override func toString() -> String {
		return self.description
	}
}

#endif

//MARK: - LakestoneError

#if !COPPER
	
/// Throwable error container
///
/// This boxed type represent the actual error object being thrown.
/// Error entity is identified with enclosed error representation.
/// Any custom type that provides its error description as required by `ErrorRepresentable`
/// protocol can be carried inside this boxed error type.
///
/// In Java this is a concrete subclass of `java.lang.Exception`,
/// the `detailMessage` of `ErrorRepresentable` is actually used as a carried exception message
/// of its superclass `java.lang.Throwable`
///
/// The recommended usage involves storing the instances of it as static variables under the
/// gathering member class type
///
///	 //sample class
///	 public class Request {
///		 
///		 //error reassambles embedded gathering class type
///		 public class Error {
///			 static let ResponseMissing = LakestoneError.with(stringRepresentation: "Response is missing")
///			 static let DestinationUnreachable = LakestoneError.with(stringRepresentation: "Destination is unreachable")
///		 }
///	 }
///
/// Within the class the error can then be thrown in a natural way:
///
///	 throw Error.DestinationUnreachable
///
/// And handled as following:
///
///	 do {
///		 let response = try HTTP("http://wrongdestination.com").performSync()
///	 } catch let error as LakestoneError {
///		 print("Error encountered: \(error.representation)")
///	 }
///
/// In Apple's swift catch clause can also be written more specifically:
///
///	 catch let error as LakestoneError where error == HTTP.Request.Error.ResponseMissing
///
/// - remark: Despite the conventional way of backing swift errors with enums,
///		   for sake of consistency with Java, it is implemented as class type
open class LakestoneError: Error {
	
	public let representation: ErrorRepresentable
	public init(_ representation: ErrorRepresentable){
		self.representation = representation
	}
}

#else

open class LakestoneError: java.lang.Exception {
		
	public let representation: ErrorRepresentable
	public init(_ representation: ErrorRepresentable){
		super.init(representation.detailMessage)
		self.representation = representation
	}
}

#endif

extension LakestoneError {
	open class func with(stringRepresentation: String) -> LakestoneError {
		return LakestoneError(StringBackedErrorType(stringRepresentation))
	}
}

extension LakestoneError: CustomStringConvertible {
	
	public var description: String {
		return self.representation.detailMessage
	}
	
	#if COOPER
	public override func toString() -> String {
		return self.description
	}
	#endif
}

extension LakestoneError: Equatable {}
public func ==(lhs: LakestoneError, rhs: LakestoneError) -> Bool {
	return lhs.representation == rhs.representation
}

#if COOPER
extension LakestoneError {
	
	public override func equals(_ o: Object!) -> Bool {
		
		guard let other = o as? Self else {
			return false
		}
		
		return (self == other)
	}
}
#endif


// Silver will catch the error as being of Object type, while in asynchronous callbacks 
// you want to return the error straight away as entity of ThrowableError type
// this is a convenience func for such purpose
#if COOPER
public func castedError(_ entity: Any) -> ThrowableError? {
    return entity as? ThrowableError
}
#else
public func castedError(_ entity: ThrowableError) -> ThrowableError? {
    return entity
}
#endif


public class DictionaryInstantiationError: LakestoneError {
    var instantiationRepresentationº: Representation? {
        return self.representation as? Representation
    }
    
    public class Representation: ErrorRepresentable {
        
        public let fieldName: String
        public let detail: String
        
        public init(fieldName: String, detail: String){
            self.fieldName = fieldName
            self.detail = detail
        }
        
        public var detailMessage: String {
            return "Entity couldn't be instantiated: error in field: \(fieldName): \(self.detail)"
        }
        
        public var error: DictionaryInstantiationError {
            return DictionaryInstantiationError(self)
        }
    }
    
    public static func defaultDetail(forType type: AnyType) -> String {
        return "Field is missing or has non \(type) type"
    }
}
