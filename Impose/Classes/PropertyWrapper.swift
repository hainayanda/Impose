//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

protocol InjectedProperty: AnyObject {
    var injector: Injector { get }
    var scopedInjector: Injector? { get set }
}

extension InjectedProperty {
    var injector: Injector {
        scopedInjector ?? Injector.shared
    }
}

@propertyWrapper
/// The wrapper of inject(for:) method
public class Injected<T>: InjectedProperty {
    public lazy var wrappedValue: T = {
        let result = resolveAndGetContext()
        self.context = result.context
        return result.value
    }()
    
    lazy var context: ImposeContext? = {
        let result = resolveAndGetContext()
        self.wrappedValue = result.value
        return result.context
    }()
    
    var scopedInjector: Injector? {
        didSet {
            let result = resolveAndGetContext()
            self.wrappedValue = result.value
            self.context = result.context
        }
    }
    
    /// Default init
    public init() { }
    
    public var projectedValue: ImposeContext? {
        context
    }
    
    func resolveAndGetContext() -> (value: T, context: ImposeContext?){
        let value = try! injector.resolve(T.self)
        let context = injector.context(of: T.self)
        return (value, context)
    }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class SafelyInjected<T>: InjectedProperty {
    public lazy var wrappedValue: T? = {
        let result = resolveAndGetContext()
        self.context = result.context
        return result.value
    }()
    
    lazy var context: ImposeContext? = {
        let result = resolveAndGetContext()
        self.wrappedValue = result.value
        return result.context
    }()
    
    var scopedInjector: Injector? {
        didSet {
            let result = resolveAndGetContext()
            self.wrappedValue = result.value
            self.context = result.context
        }
    }
    /// Default init
    public init() { }
    
    public var projectedValue: ImposeContext? {
        context
    }
    
    func resolveAndGetContext() -> (value: T?, context: ImposeContext?){
        let value = try? injector.resolve(T.self)
        let context = injector.context(of: T.self)
        return (value, context)
    }
}
