//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

protocol ScopeInjectable: AnyObject {
    func applyScope(by context: InjectContext)
}

@propertyWrapper
/// The wrapper of inject(for:) method
public class Injected<T>: ScopeInjectable, ScopedInitiable {
    public var wrappedValue: T {
        inject(T.self, scopedBy: scopeContext)
    }
    
    var scopeContext: InjectContext?
    
    /// Default init
    public init() { }
    
    public required init(using context: InjectContext) {
        scopeContext = context
    }
    
    func applyScope(by context: InjectContext) {
        self.scopeContext = context
    }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class SafelyInjected<T>: ScopeInjectable, ScopedInitiable {
    public var wrappedValue: T? {
        injectIfProvided(for: T.self, scopedBy: scopeContext)
    }
    
    var scopeContext: InjectContext?
    
    /// Default init
    public init() { }
    
    public required init(using context: InjectContext) {
        scopeContext = context
    }
    
    public static func scoped(by context: InjectContext) -> SafelyInjected<T> {
        let wrapper = SafelyInjected()
        wrapper.applyScope(by: context)
        return wrapper
    }
    
    func applyScope(by context: InjectContext) {
        self.scopeContext = context
    }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class Scoped<T: Scopable>: ScopeInjectable {
    public var wrappedValue: T {
        didSet {
            injectWrappedIfNeeded()
        }
    }
    
    var scopeContext: InjectContext? {
        didSet {
            injectWrappedIfNeeded()
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public init(wrappedValue: T, context: InjectContext) {
        self.wrappedValue = wrappedValue
        self.scopeContext = context
        injectWrappedIfNeeded()
    }
    
    public init(wrappedValue: T, scope: Scopable) {
        self.wrappedValue = wrappedValue
        self.scopeContext = scope.scopeContext
        injectWrappedIfNeeded()
    }
    
    func injectWrappedIfNeeded() {
        guard let scopeContext = scopeContext else {
            return
        }
        wrappedValue.scoped(by: scopeContext)
    }
    
    func applyScope(by context: InjectContext) {
        self.scopeContext = context
    }
}
