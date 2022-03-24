//
//  InjectResolving.swift
//  Impose
//
//  Created by Nayanda Haberty on 24/03/22.
//

import Foundation

// MARK: InjectResolving

public protocol InjectResolving: AnyObject {
    func resolve<T>(_ type: T.Type) throws -> T
}

// MARK: InjectResolver

public class InjectResolver: InjectResolving {
    
    var resolvers: [TypeHashable: InstanceResolver]
    var cachedResolvers: [TypeHashable: InstanceResolver]
    
    /// Default init
    public init() {
        self.resolvers = [:]
        self.cachedResolvers = [:]
    }
    
    // MARK: Resolve
    
    /// resolve instance from the given type. It will throws error if occured
    /// - Parameter type: type
    /// - Throws: ImposeError
    /// - Returns: instance resolved
    public func resolve<T>(_ type: T.Type) throws -> T {
        guard let resolver = resolvers[type] ?? cachedResolvers[type] else {
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
            cachedResolvers[type] = resolver
            return instance
        }
        throw ImposeError(
            errorDescription: "Impose Error: fail when search for imposed instance",
            failureReason: "No compatible resolver for \(String(describing:T.self))"
        )
    }
    
    // MARK: Internal Methods
    
    func findPotentialProviders<T>(for type: T.Type) -> [InstanceResolver] {
        resolvers.values.reduce([InstanceResolver]()) { partialResult, value in
            guard value.isPotentialResolver(of: type) else {
                return partialResult
            }
            var result = partialResult
            result.append(value)
            return result
        }.sorted { resolver1, resolver2 in
            resolver2.canBeResolved(by: resolver1)
        }
    }
    
    func cleanCachedAndGroup() {
        cachedResolvers.removeAll()
    }
}
