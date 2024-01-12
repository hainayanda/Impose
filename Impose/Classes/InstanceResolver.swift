//
//  InstanceProvider.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation
import Chary

// MARK: InstanceResolver protocol

protocol InstanceResolver: AnyObject {
    func isExactResolver<T>(of anyType: T.Type) -> Bool
    func isResolver<T>(of anyType: T.Type) -> Bool
    func canBeResolved(by otherResolver: InstanceResolver) -> Bool
    func resolveInstance() -> Any
}

// MARK: InstanceProvider class

class InstanceProvider<Instance>: InstanceResolver {
    
    typealias Resolver = () -> Instance
    
    @inlinable func canBeResolved(by otherResolver: InstanceResolver) -> Bool {
        otherResolver.isResolver(of: Instance.self)
    }
    
    @inlinable func isExactResolver<T>(of anyType: T.Type) -> Bool {
        anyType == Instance.self
    }
    
    @inlinable func isResolver<T>(of anyType: T.Type) -> Bool {
        isExactResolver(of: anyType) || isType(Instance.self, implement: T.self) || isType(Instance.self, subclassOf: T.self)
    }
    
    @inlinable func resolveInstance() -> Any {
        fatalError("should be overridden")
    }
}

// MARK: SingleInstanceProvider class

final class SingleInstanceProvider<Instance>: InstanceProvider<Instance> {
    private var _resolver: Resolver?
    var resolver: Resolver { _resolver! }
    
    var resolved: Bool { _resolver == nil }
    
    let queue: DispatchQueue?
    
    private lazy var _instance: Instance = queue?.safeSync(execute: resolver) ?? resolver()
    var instance: Instance {
        defer { _resolver = nil }
        return _instance
    }
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Instance) {
        self._resolver = resolver
        self.queue = queue
    }
    
    @inlinable override func isResolver<T>(of anyType: T.Type) -> Bool {
        if super.isResolver(of: anyType) {
            return true
        } else if resolved {
            return instance is T
        }
        return false
    }
    
    @inlinable override func resolveInstance() -> Any {
        instance
    }
}

// MARK: FactoryInstanceProvider class

final class FactoryInstanceProvider<Instance>: InstanceProvider<Instance> {
    let resolver: Resolver
    let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Instance) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable override func resolveInstance() -> Any {
        queue?.safeSync(execute: resolver) ?? resolver()
    }
}

final class WeakSingleInstanceProvider<Instance: AnyObject>: InstanceProvider<Instance> {
    let resolver: Resolver
    let queue: DispatchQueue?
    weak var instance: Instance?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Instance) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable override func isResolver<T>(of anyType: T.Type) -> Bool {
        if super.isResolver(of: anyType) {
            return true
        } else if let instance = instance {
            return instance is T
        }
        return false
    }
    
    @inlinable override func resolveInstance() -> Any {
        guard let instance = instance else {
            let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
            self.instance = newInstance
            return newInstance
        }
        return instance
    }
}

func isType<C>(_ type: Any.Type, subclassOf superType: C.Type) -> Bool {
    type is C.Type
}

func isType<P>(_ type: Any.Type, implement anyObjectProtocol: P.Type) -> Bool {
    type is P
}
