//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

protocol InjectedProperty: AnyObject {
    var scopedInjector: InjectResolving? { get set }
}

@propertyWrapper
/// The wrapper of inject(for:) method
public class Injected<T>: InjectedProperty {
    public lazy var wrappedValue: T = inject(T.self, scopedBy: scopedInjector)
    
    var scopedInjector: InjectResolving? {
        didSet {
            wrappedValue = inject(T.self, scopedBy: scopedInjector)
        }
    }
    
    /// Default init
    public init() { }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class SafelyInjected<T>: InjectedProperty {
    public lazy var wrappedValue: T? = injectIfProvided(for: T.self, scopedBy: scopedInjector)
    
    var scopedInjector: InjectResolving? {
        didSet {
            wrappedValue = injectIfProvided(for: T.self, scopedBy: scopedInjector)
        }
    }
    /// Default init
    public init() { }
}
