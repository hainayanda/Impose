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
    func isPotentialResolver(of anyType: Any.Type) -> Bool
    func resolveInstance() -> Any
    func cloneWithNoInstance() -> InstanceResolver
}

// MARK: InstanceProvider class

class InstanceProvider<Instance>: InstanceResolver {
    
    func canBeResolved(by otherResolver: InstanceResolver) -> Bool {
        otherResolver.isResolver(of: Instance.self)
    }
    
    func isResolver<T>(of anyType: T.Type) -> Bool {
        Instance.self is T.Type
    }
    
    func isPotentialResolver(of anyType: Any.Type) -> Bool {
        anyType is Instance.Type
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
    lazy var instance: Instance = resolver()
    
    init(resolver: @escaping () -> Instance) {
        self.resolver = resolver
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
