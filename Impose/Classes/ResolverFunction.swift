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

/// get instance of the given type. It will use given closure if fail
/// - Parameters:
///   - type: type of instance
///   - resolve: closure resolver to call if inject fail
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type, ifFail resolve: () -> T) -> T {
    do {
        return try Injector.shared.resolve(type)
    } catch {
        return resolve()
    }
}

/// get instance of the given type. It will use given autoclosure if fail
/// - Parameters:
///   - type: type of instance
///   - resolve: autoclosure resolver to call if inject fail
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type, ifFailUse resolve: @autoclosure () -> T) -> T {
    do {
        return try Injector.shared.resolve(type)
    } catch {
        return resolve()
    }
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
