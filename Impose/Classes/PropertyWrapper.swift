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
    public lazy var wrappedValue: T = inject(ifNoMatchUse: rules)
    let rules: InjectionRules
    
    /// Default init
    /// - Parameter rules: rules to search type when same type is not found
    public init(ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
    }
}

@propertyWrapper
/// The wrapper of unforceInject(ifNoMatchUse:) method
public struct UnforceInjected<T> {
    public lazy var wrappedValue: T? = unforceInject(ifNoMatchUse: rules)
    let rules: InjectionRules
    
    /// Default init
    /// - Parameter rules: rules to search type when same type is not found
    public init(ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
    }
}
