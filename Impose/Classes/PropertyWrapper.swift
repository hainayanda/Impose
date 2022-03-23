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
    
    let rules: InjectionRules
    let type: ImposerType
    
    @available(*, deprecated, message: "Use no param instead, will be removed in next release")
    public init(type: ImposerType) {
        self.rules = .nearest
        self.type = type
    }
    
    @available(*, deprecated, message: "Use no param instead, will be removed in next release")
    public init(ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
        self.type = .primary
    }
    
    /// Default init
    public init() {
        self.rules = .nearest
        self.type = .primary
    }
    
    public var projectedValue: ImposeContext? {
        context
    }
    
    func resolveAndGetContext() -> (value: T, context: ImposeContext?){
        do {
            let value = try injector.resolve(T.self)
            let context = injector.context(of: T.self)
            return (value, context)
        } catch {
            // will be removed on next release
            let value: T = inject(from: type, ifNoMatchUse: rules)
            return (value, nil)
        }
    }
}

@propertyWrapper
@available(*, deprecated, message: "Use ModuleProvider instead, will be removed in next release")
public class UnforceInjected<T> {
    public lazy var wrappedValue: T? = unforceInject(from: type, ifNoMatchUse: rules)
    let rules: InjectionRules
    let type: ImposerType
    
    public init(type: ImposerType = .primary, ifNoMatchUse rules: InjectionRules = .nearest) {
        self.rules = rules
        self.type = type
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
