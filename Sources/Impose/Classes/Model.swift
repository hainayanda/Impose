//
//  Model.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

protocol Provider {
    func canBeProvided(by otherProvider: Provider) -> Bool
    func isProvider<TypeToProvide>(of anyType: TypeToProvide.Type) -> Bool
    func isPotentialProvider(of anyType: Any.Type) -> Bool
    func isSameType(of anyType: Any.Type) -> Bool
    func getInstance() -> Any
}

class InjectProvider<T>: Provider {
    var provider: () -> T
    lazy var providedInstance: T = provider()
    var option: InjectOption
    init(option: InjectOption, _ provider: @escaping () -> T) {
        self.provider = provider
        self.option = option
    }
    
    func canBeProvided(by otherProvider: Provider) -> Bool {
        otherProvider.isProvider(of: T.self)
    }
    
    func isProvider<TypeToProvide>(of anyType: TypeToProvide.Type) -> Bool {
        T.self is TypeToProvide.Type
    }
    
    func isPotentialProvider(of anyType: Any.Type) -> Bool {
        anyType is T.Type
    }
    
    func isSameType(of anyType: Any.Type) -> Bool {
        anyType == T.self
    }
    
    func getInstance() -> Any {
        switch option {
        case .singleton:
            return providedInstance
        default:
            return provider()
        }
    }
}

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
/// singleton means the instance is only created once
/// alwaysNew means the instance is created everytime needed
public enum InjectOption {
    case singleton
    case alwaysNew
}

/// Injection rules
/// nearestType which means return nearest type requested
/// furthestType which means return furthest type requested
public enum InjectionRules {
    case nearestType
    case furthestType
}
