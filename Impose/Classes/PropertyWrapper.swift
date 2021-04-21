//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

@propertyWrapper
/// The wrapper of inject(ifNoMatchUse:) method
public struct Injected<T> {
    public lazy var wrappedValue: T = inject(from: type, ifNoMatchUse: rules)
    let rules: InjectionRules
    let type: ImposerType
    
    /// Default init
    /// - Parameter rules: rules to search type when same type is not found
    /// - Parameter type: type of imposer to search dependency. if not found, will try to search from other imposer
    public init(type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
        self.type = type
    }
}

@propertyWrapper
/// The wrapper of unforceInject(ifNoMatchUse:) method
public struct UnforceInjected<T> {
    public lazy var wrappedValue: T? = unforceInject(from: type, ifNoMatchUse: rules)
    let rules: InjectionRules
    let type: ImposerType
    
    /// Default init
    /// - Parameter rules: rules to search type when same type is not found
    /// - Parameter type: type of imposer to search dependency. if not found, will try to search from other imposer
    public init(type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
        self.type = type
    }
}
