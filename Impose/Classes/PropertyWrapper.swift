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
    private var assignedManually: Bool = false
    private lazy var _wrappedValue: T? = inject(T.self, scopedBy: scopeContext)
    public var wrappedValue: T {
        get {
            guard let wrappedValue = _wrappedValue else {
                let value = inject(T.self, scopedBy: scopeContext)
                _wrappedValue = value
                return value
            }
            return wrappedValue
        } set {
            assignedManually = true
            _wrappedValue = newValue
        }
    }
    
    var scopeContext: InjectContext? {
        didSet {
            guard !assignedManually else {
                return
            }
            _wrappedValue = nil
        }
    }
    
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
    private var assignedManually: Bool = false
    private lazy var _wrappedValue: T? = injectIfProvided(for: T.self, scopedBy: scopeContext)
    public var wrappedValue: T? {
        get {
            guard !assignedManually else {
                return _wrappedValue
            }
            guard let wrappedValue = _wrappedValue else {
                _wrappedValue = injectIfProvided(for: T.self, scopedBy: scopeContext)
                return _wrappedValue
            }
            return wrappedValue
        } set {
            assignedManually = true
            _wrappedValue = newValue
        }
    }
    
    var scopeContext: InjectContext? {
        didSet {
            guard !assignedManually else {
                return
            }
            _wrappedValue = nil
        }
    }
    
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
