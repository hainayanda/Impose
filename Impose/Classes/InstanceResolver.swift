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
}

// MARK: SingleInstanceProvider class

class SingleInstanceProvider<Instance>: InstanceProvider<Instance> {
    var temporaryProvider: (() -> Instance)?
    lazy var instance: Instance = {
        let newInstance = temporaryProvider!()
        temporaryProvider = nil
        return newInstance
    }()
    
    init(resolver: @escaping () -> Instance) {
        self.temporaryProvider = resolver
    }
    
    override func resolveInstance() -> Any {
        instance
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
}
