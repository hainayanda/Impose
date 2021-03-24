//
//  Model.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

/// Error object generated from Impose
public struct ImposeError: LocalizedError {
    
    /// Description of error
    public let errorDescription: String?
    
    /// Reason of failure
    public let failureReason: String?
    
    init(errorDescription: String, failureReason: String? = nil) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
    }
}

/// Inject option
/// singleInstance means the closure is only called once
/// closureBased means the instance is always coming from closure
public enum InjectOption {
    case singleInstance
    case closureBased
    
    func createProvider<T>(_ provider: @escaping () -> T) -> Provider {
        switch self {
        case .closureBased:
            return ClosureBasedProvider(provider)
        case .singleInstance:
            return StorageBasedProvider(provider)
        }
    }
}

/// Injection rules
/// nearest which means return nearest type requested
/// furthest which means return furthest type requested
/// nearestAndCastable which means return nearest type requested and using type casting
/// furthestAndCastable which means return furthest type requested and using type casting
public enum InjectionRules {
    case nearest
    case furthest
    case nearestAndCastable
    case furthestAndCastable
    
    var useCasting: Bool {
        switch self {
        case .nearest, .furthest:
            return false
        case .furthestAndCastable, .nearestAndCastable:
            return true
        }
    }
}
