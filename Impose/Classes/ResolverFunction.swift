//
//  ResolverFunction.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// get instance of the given type. It will throw ImposeError if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Throws: ImposeError
/// - Returns: instance resolved
public func tryInject<T>(_ type: T.Type, scopedBy injector: Injector = Injector.shared) throws -> T {
    try injector.resolve(type)
}

/// get instance of the given type. It will use given closure if fail
/// - Parameters:
///   - type: type of instance
///   - resolve: closure resolver to call if inject fail
///   - injector: Injector that will resolve the instance
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type, scopedBy injector: Injector = Injector.shared, ifFail resolve: () -> T) -> T {
    do {
        return try injector.resolve(type)
    } catch {
        return resolve()
    }
}

/// get instance of the given type. It will use given autoclosure if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
///   - resolve: autoclosure resolver to call if inject fail
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type, scopedBy injector: Injector = Injector.shared, ifFailUse resolve: @autoclosure () -> T) -> T {
    do {
        return try injector.resolve(type)
    } catch {
        return resolve()
    }
}

/// get instance of the given type. It will throws fatal error if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Returns: instance resolved
public func inject<T>(_ type: T.Type, scopedBy injector: Injector = Injector.shared) -> T {
    try! tryInject(type, scopedBy: injector)
}

/// get instance of the given type. it will return nil if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Returns: instance resolved if found and nil if not
public func injectIfProvided<T>(for type: T.Type, scopedBy injector: Injector = Injector.shared) -> T? {
    try? tryInject(type, scopedBy: injector)
}
