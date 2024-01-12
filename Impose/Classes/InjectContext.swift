//
//  InjectContext.swift
//  Impose
//
//  Created by Nayanda Haberty on 24/03/22.
//

import Foundation
import Chary

// MARK: InjectResolving

public protocol InjectContext: AnyObject {
    func resolve<T>(_ type: T.Type) throws -> T
}

// MARK: InjectResolver

public class InjectResolver: InjectContext {
    
    @Atomic var mappedResolvers: [TypeHashable: InstanceResolver] = [:]
    @Atomic var cachedMappedResolvers: [TypeHashable: InstanceResolver] = [:]
    @Atomic var resolvers: [InstanceResolver] = []
    lazy var atomicQueue: DispatchQueue = .init(label: "InjectResolver_\(UUID().uuidString)")
    
    /// Default init
    public init() {
        $mappedResolvers = atomicQueue
        $cachedMappedResolvers = atomicQueue
        $resolvers = atomicQueue
    }
    
    /// Remove all provider
    public func reset() {
        sync {
            self.mappedResolvers = [:]
            self.cachedMappedResolvers = [:]
            self.resolvers = []
        }
    }
    
    // MARK: Resolve
    
    /// Resolve instance from the given type. It will throws error if occured.
    /// Time complexity will be O(1) and O(n) for worst case scenario.
    /// At the worst scenario, it will then cached the type and provider so at the next method call with the same type it will O(log n)
    /// - Parameter type: type
    /// - Throws: ImposeError
    /// - Returns: instance resolved
    public func resolve<T>(_ type: T.Type) throws -> T {
        try sync {
            guard let resolver = mappedResolvers[type] ?? cachedMappedResolvers[type] else {
                return try findAndCachedCompatibleInstance(of: type)
            }
            guard let instance = resolver.resolveInstance() as? T else {
                throw ImposeError(
                    errorDescription: "Impose Error: fail when resolving instance",
                    failureReason: "Provider instance type is not compatible for \(T.self)"
                )
            }
            return instance
        }
    }
    
    // MARK: Internal Method
    
    func findAndCachedCompatibleInstance<T>(of type: T.Type) throws -> T {
        let potentialProviders = findPotentialResolvers(for: type)
        for resolver in potentialProviders {
            guard let instance = resolver.resolveInstance() as? T else {
                continue
            }
            cachedMappedResolvers[type] = resolver
            return instance
        }
        throw ImposeError(
            errorDescription: "Impose Error: fail when search for imposed instance",
            failureReason: "No compatible resolver for \(T.self)"
        )
    }
    
    func findPotentialResolvers<T>(for type: T.Type) -> [InstanceResolver] {
        resolvers.reduce([InstanceResolver]()) { partialResult, value in
            guard value.isResolver(of: type) else {
                return partialResult
            }
            var result = partialResult
            result.append(value)
            return result
        }.sorted { resolver1, resolver2 in
            if resolver1.isExactResolver(of: T.self) {
                return true
            } else if resolver2.isExactResolver(of: T.self) {
                return false
            } else {
                return resolver2.canBeResolved(by: resolver1)
            }
        }
    }
    
    func cleanCachedAndRepopulate() {
        cachedMappedResolvers.removeAll()
        resolvers = mappedResolvers.uniqueValueInstances
    }
    
    func sync<T>(_ work: () throws -> T) rethrows -> T {
        try atomicQueue.safeSync(flags: .barrier, execute: work)
    }
}
