//
//  InstanceProvider.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

// MARK: InstanceResolver protocol

protocol InstanceResolver: AnyObject {
    func isResolver<T>(of anyType: T.Type) -> Bool
    func canBeResolved(by otherResolver: InstanceResolver) -> Bool
    func resolveInstance() -> Any
    func cloneWithNoInstance() -> InstanceResolver
}

// MARK: InstanceProvider class

class InstanceProvider<Instance>: InstanceResolver {
    
    func canBeResolved(by otherResolver: InstanceResolver) -> Bool {
        otherResolver.isResolver(of: Instance.self)
    }
    
    func isResolver<T>(of anyType: T.Type) -> Bool {
        anyType == Instance.self || isType(Instance.self, implement: T.self)
    }
    
    func resolveInstance() -> Any {
        fatalError("should be overridden")
    }
    
    func cloneWithNoInstance() -> InstanceResolver {
        fatalError("should be overridden")
    }
}

// MARK: SingleInstanceProvider class

class SingleInstanceProvider<Instance>: InstanceProvider<Instance> {
    var resolver: () -> Instance
    var resolved: Bool = false
    private lazy var _instance: Instance = resolver()
    var instance: Instance {
        get {
            defer { resolved = true }
            return _instance
        }
    }
    
    init(resolver: @escaping () -> Instance) {
        self.resolver = resolver
    }
    
    override func isResolver<T>(of anyType: T.Type) -> Bool {
        if super.isResolver(of: anyType) {
            return true
        } else if resolved {
            return instance is T
        }
        return false
    }
    
    override func resolveInstance() -> Any {
        instance
    }
    
    override func cloneWithNoInstance() -> InstanceResolver {
        SingleInstanceProvider(resolver: resolver)
    }
}

// MARK: FactoryInstanceProvider class

class FactoryInstanceProvider<Instance>: InstanceProvider<Instance> {
    var resolver: () -> Instance
    
    init(resolver: @escaping () -> Instance) {
        self.resolver = resolver
    }
    
    override func resolveInstance() -> Any {
        return resolver()
    }
    
    override func cloneWithNoInstance() -> InstanceResolver {
        FactoryInstanceProvider(resolver: resolver)
    }
}

class WeakSingleInstanceProvider<Instance: AnyObject>: InstanceProvider<Instance> {
    var resolver: () -> Instance
    weak var instance: Instance?
    
    init(resolver: @escaping () -> Instance) {
        self.resolver = resolver
    }
    
    override func isResolver<T>(of anyType: T.Type) -> Bool {
        if super.isResolver(of: anyType) {
            return true
        } else if let instance = instance {
            return instance is T
        }
        return false
    }
    
    override func resolveInstance() -> Any {
        guard let instance = instance else {
            let newInstance = resolver()
            self.instance = newInstance
            return newInstance
        }
        return instance
    }
    
    override func cloneWithNoInstance() -> InstanceResolver {
        WeakSingleInstanceProvider(resolver: resolver)
    }
}

func isType<C: AnyObject>(_ type: Any.Type, subclassOf superType: C.Type) -> Bool {
    type is C.Type
}

func isType<P>(_ type: Any.Type, implement anyObjectProtocol: P.Type) -> Bool {
    type is P
}
