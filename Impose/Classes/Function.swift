//
//  Function.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

/// Function to get instance from provider that throw catchable error
/// - Parameter anyType: Type of instance
/// - Parameter type: type of imposer, will try to check from other imposer if dependency is not found
/// - Parameter rules: Injection rules
/// - Throws: ImposeError, mostly if provider is not there
/// - Returns: The provided instance
public func tryInject<T>(from type: ImposerType = .primary, of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearest) throws -> T {
    do {
        return try Imposer.imposer(of: type).imposedInstance(of: anyType, ifNoMatchUse: rules)
    } catch {
        let otherImposerTypes = Imposer.imposers.keys.sorted().filter { $0 != type }
        for type in otherImposerTypes {
            guard let imposer = try? Imposer.imposer(of: type).imposedInstance(of: anyType, ifNoMatchUse: rules) else {
                continue
            }
            return imposer
        }
        throw error
    }
}

/// Function to get instance from provider that throw uncatchable error
/// - Parameter anyType: Type of instance
/// - Parameter type: type of imposer, will try to check from other imposer if dependency is not found
/// - Parameter rules: Injection rules
/// - Returns: The provided instance
public func inject<T>(from type: ImposerType = .primary, of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearest) -> T {
    try! tryInject(from: type, of: anyType, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw catchable error
/// - Throws: ImposeError, mostly if provider is not there
/// - Returns: The provided instance
public func tryInject<T>(from type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) throws -> T {
    try tryInject(from: type, of: T.self, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Returns: The provided instance
/// - Parameters:
///   - type: type of imposer, will try to check from other imposer if dependency is not found
///   - rules: Injection rules
public func inject<T>(from type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) -> T {
    inject(from: type, of: T.self, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Parameter anyType: Type of instance
/// - Parameter type: type of imposer, will try to check from other imposer if dependency is not found
/// - Parameter rules: Injection rules
/// - Returns: The provided instance
public func unforceInject<T>(from type: ImposerType = .primary, of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearest) -> T? {
    try? tryInject(from: type, of: anyType, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Returns: The provided instance
/// - Parameters:
///   - type: type of imposer, will try to check from other imposer if dependency is not found
///   - rules: Injection rules
public func unforceInject<T>(from type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) -> T? {
    try? tryInject(from: type, of: T.self, ifNoMatchUse: rules)
}
