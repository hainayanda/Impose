//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

protocol EnvironmentInjectable: AnyObject {
    func provided(by context: InjectContext)
}

@propertyWrapper
/// The wrapper of inject(for:) method
public class Injected<T>: EnvironmentInjectable {
    private var assignedManually: Bool = false
    private lazy var _wrappedValue: T? = inject(T.self, providedBy: scopeContext)
    public var wrappedValue: T {
        get {
            guard let wrappedValue = _wrappedValue else {
                let value = inject(T.self, providedBy: scopeContext)
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
    
    func provided(by context: InjectContext) {
        self.scopeContext = context
    }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class SafelyInjected<T>: EnvironmentInjectable {
    private var assignedManually: Bool = false
    private lazy var _wrappedValue: T? = injectIfProvided(for: T.self, providedBy: context)
    public var wrappedValue: T? {
        get {
            guard !assignedManually else {
                return _wrappedValue
            }
            guard let wrappedValue = _wrappedValue else {
                _wrappedValue = injectIfProvided(for: T.self, providedBy: context)
                return _wrappedValue
            }
            return wrappedValue
        } set {
            assignedManually = true
            _wrappedValue = newValue
        }
    }
    
    var context: InjectContext? {
        didSet {
            guard !assignedManually else {
                return
            }
            _wrappedValue = nil
        }
    }
    
    /// Default init
    public init() { }
    
    func provided(by context: InjectContext) {
        self.context = context
    }
}

@available(*, deprecated, message: "Use Environment instead")
@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class Scoped<T: Scopable>: EnvironmentInjectable {
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
    
    func provided(by context: InjectContext) {
        self.scopeContext = context
    }
}
