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

protocol ManualAssignedProviderExtractable {
    func manualAssignedProvider() -> (Any.Type, InstanceResolver)?
}

@propertyWrapper
/// The wrapper of inject(for:) method
public class Injected<T>: EnvironmentInjectable, ManualAssignedProviderExtractable {
    private var assignedManually: Bool = false
    private var _wrappedValue: T?
    public var wrappedValue: T {
        get {
            guard let wrappedValue = _wrappedValue else {
                let value = inject(T.self, providedBy: context)
                _wrappedValue = value
                return value
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
    
    func manualAssignedProvider() -> (Any.Type, InstanceResolver)? {
        guard assignedManually, let instance = _wrappedValue else { return nil }
        return (T.self, SingleInstanceProvider(queue: nil) { instance })
    }
}

@propertyWrapper
/// The wrapper of injectIfProvided(for:) method
public class SafelyInjected<T>: EnvironmentInjectable, ManualAssignedProviderExtractable {
    private var assignedManually: Bool = false
    private var _wrappedValue: T?
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
    
    func manualAssignedProvider() -> (Any.Type, InstanceResolver)? {
        guard assignedManually, let instance = _wrappedValue else { return nil }
        return (T.self, SingleInstanceProvider(queue: nil) { instance })
    }
}
