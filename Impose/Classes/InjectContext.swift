//
//  InjectContext.swift
//  Impose
//
//  Created by Nayanda Haberty on 24/03/22.
//

import Foundation

// MARK: InjectResolving

public protocol InjectContext: AnyObject {
    func resolve<T>(_ type: T.Type) throws -> T
}

// MARK: InjectResolver

public class InjectResolver: InjectContext {
    
    var mappedResolvers: [TypeHashable: InstanceResolver]
    var cachedMappedResolvers: [TypeHashable: InstanceResolver]
    var resolvers: [InstanceResolver]
    
    /// Default init
    public init() {
        self.mappedResolvers = [:]
        self.cachedMappedResolvers = [:]
        self.resolvers = []
    }
    
    /// Remove all provider
    public func reset() {
        self.mappedResolvers = [:]
        self.cachedMappedResolvers = [:]
        self.resolvers = []
    }
    
    // MARK: Resolve
    
    /// Resolve instance from the given type. It will throws error if occured.
    /// Time complexity will be O(log n) and O(n) for worst case scenario.
    /// At the worst scenario, it will then cached the type and provider so at the next method call with the same type it will O(log n)
    /// - Parameter type: type
    /// - Throws: ImposeError
    /// - Returns: instance resolved
    public func resolve<T>(_ type: T.Type) throws -> T {
        guard let resolver = mappedResolvers[type] ?? cachedMappedResolvers[type] else {
            return try findAndCachedCompatibleInstance(of: type)
        }
        guard let instance = resolver.resolveInstance() as? T else {
            throw ImposeError(
                errorDescription: "Impose Error: fail when resolving instance",
                failureReason: "Provider instance type is not compatible for \(String(describing:T.self))"
            )
        }
        return instance
    }
    
    // MARK: Internal Method
    
    func findAndCachedCompatibleInstance<T>(of type: T.Type) throws -> T {
        let potentialProviders = findPotentialProviders(for: type)
        for resolver in potentialProviders {
            guard let instance = resolver.resolveInstance() as? T else {
                continue
            }
            cachedMappedResolvers[type] = resolver
            return instance
        }
        throw ImposeError(
            errorDescription: "Impose Error: fail when search for imposed instance",
            failureReason: "No compatible resolver for \(String(describing:T.self))"
        )
    }
    
    // MARK: Internal Methods
    
    func findPotentialProviders<T>(for type: T.Type) -> [InstanceResolver] {
        resolvers.reduce([InstanceResolver]()) { partialResult, value in
            guard value.isResolver(of: type) else {
                return partialResult
            }
            var result = partialResult
            result.append(value)
            return result
        }.sorted { resolver1, resolver2 in
            resolver2.canBeResolved(by: resolver1)
        }
    }
    
    func cleanCachedAndRepopulate() {
        cachedMappedResolvers.removeAll()
        resolvers = mappedResolvers.uniqueValueInstances
    }
}
