//
//  ResolverFunction.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// get instance of the given type. It will throw ImposeError if fail
/// - Parameter type: type of instance
/// - Throws: ImposeError
/// - Returns: instance resolved
public func tryInject<T>(_ type: T.Type) throws -> T {
    try Injector.shared.resolve(type)
}

/// get instance of the given type. It will throws fatal error if fail
/// - Parameter type: type of instance
/// - Returns: instance resolved
public func inject<T>(_ type: T.Type) -> T {
    try! tryInject(type)
}

/// get instance of the given type. it will return nil if fail
/// - Parameter type: type of instance
/// - Returns: instance resolved if found and nil if not
public func injectIfProvided<T>(for type: T.Type) -> T? {
    try? tryInject(type)
}
