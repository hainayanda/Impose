//
//  Function.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

/// Function to get instance from provider that throw catchable error
/// - Parameter anyType: Type of instance
/// - Throws: ImposeError, mostly if provider is not there
/// - Returns: The provided instance
public func tryInject<T>(of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearestType) throws -> T {
    try Imposer.shared.imposedInstance(of: anyType, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Parameter anyType: Type of instance
/// - Returns: The provided instance
public func inject<T>(of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearestType) -> T {
    try! Imposer.shared.imposedInstance(of: anyType, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw catchable error
/// - Throws: ImposeError, mostly if provider is not there
/// - Returns: The provided instance
public func tryInject<T>(ifNoMatchUse rules: InjectionRules = .nearestType) throws -> T {
    try Imposer.shared.imposedInstance(of: T.self, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Returns: The provided instance
public func inject<T>(ifNoMatchUse rules: InjectionRules = .nearestType) -> T {
    try! Imposer.shared.imposedInstance(of: T.self, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Parameter anyType: Type of instance
/// - Returns: The provided instance
public func unforceInject<T>(of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearestType) -> T? {
    try? Imposer.shared.imposedInstance(of: anyType, ifNoMatchUse: rules)
}

/// Function to get instance from provider that throw uncatchable error
/// - Returns: The provided instance
public func unforceInject<T>(ifNoMatchUse rules: InjectionRules = .nearestType) -> T? {
    try? Imposer.shared.imposedInstance(of: T.self, ifNoMatchUse: rules)
}
