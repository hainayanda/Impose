//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// will uncoment in next release
//public typealias Imposer = Injector

/// Injector class
public class Injector: Clonable {
    
    // MARK: Public Static
    
    /// shared instance of active Injector
    public static var shared: Injector {
        customInjector ?? defaultInjector
    }
    
    /// Default scoped context
    public static let sharedContext: ImposeContext = ImposeContext()
    
    /// switch shared imposer with the one you prefer
    /// - Parameter newImposer: new Injector that will replace shared instance
    public static func switchInjector(to newInjector: Injector) {
        self.customInjector = newInjector
    }
    
    /// switch shared to default Injector
    public static func switchToDefaultInjector() {
        self.customInjector = nil
    }
    
    // MARK: Internal Static
    
    static let defaultInjector: Injector = Injector()
    static var customInjector: Injector?
    
    // MARK: Internal Properties
    
    var contextGroups: [ContextGroup]
    var resolvers: [TypeHashable: InstanceResolver]
    var cachedResolvers: [TypeHashable: InstanceResolver]
    
    // MARK: Public Properties
    
    /// Default init
    public init() {
        self.contextGroups = []
        self.resolvers = [:]
        self.cachedResolvers = [:]
    }
    
    // MARK: Public Method
    
    public func asScopedInjector() -> Injector {
        clone() as! Injector
    }
    
    // MARK: Transient
    
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addTransient<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        resolvers[anyType] = FactoryInstanceProvider(resolver: resolver)
        cleanCachedAndGroup()
    }
    
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addTransient<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = FactoryInstanceProvider(resolver: resolver)
        for type in anyTypes {
            resolvers[type] = resolver
        }
        cleanCachedAndGroup()
    }
    
    // MARK: Singleton
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addSingleton<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        resolvers[anyType] = SingleInstanceProvider(resolver: resolver)
        cleanCachedAndGroup()
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addSingleton<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = SingleInstanceProvider(resolver: resolver)
        for type in anyTypes {
            resolvers[type] = resolver
        }
        cleanCachedAndGroup()
    }
    
    // MARK: Scoped
    
    /// provide scoped resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - context: scoped context, it will use Injector.sharedContext if not provided
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addScoped<T>(for anyType: Any.Type, in context: ImposeContext = Injector.sharedContext, resolver: @escaping () -> T) {
        let resolver = ContextInstanceProvider(resolver: resolver)
        let group = contextGroups.first { $0.isGroup(of: context) } ?? ContextGroup(for: context)
        group.add(resolver: resolver)
        context.add(resolver: resolver)
        resolvers[anyType] = resolver
        cleanCachedAndGroup()
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - context: scoped context, it will use Injector.sharedContext if not provided
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addScoped<T>(for anyTypes: [Any.Type], in context: ImposeContext = Injector.sharedContext, resolver: @escaping () -> T) {
        let resolver = ContextInstanceProvider(resolver: resolver)
        let group = contextGroups.first { $0.isGroup(of: context) } ?? ContextGroup(for: context)
        group.add(resolver: resolver)
        context.add(resolver: resolver)
        for type in anyTypes {
            resolvers[type] = resolver
        }
        cleanCachedAndGroup()
    }
    
    // MARK: Module
    
    /// It will automatically run module injector provide(for:) with its service imposer
    /// - Parameter moduleProvider: the ModuleProvider
    public func provide(using moduleProvider: ModuleProvider) {
        moduleProvider.provide(for: self)
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
    
    // MARK: Context
    
    /// get context of the given type if have any
    /// - Parameter type: type of resolver
    /// - Returns: ImposeContext found
    public func context(of type: Any.Type) -> ImposeContext? {
        guard let resolver = resolvers[type] ?? cachedResolvers[type]else {
            return nil
        }
        return contextGroups.first { $0.isGroup(of: resolver) }?.context
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
    
    func cleanCachedAndGroup() {
        for contextGroup in contextGroups {
            contextGroup.remove(allNotIn: resolvers)
        }
        cachedResolvers.removeAll()
    }
    
    func clone() -> Any {
        let myClone = Injector()
        myClone.contextGroups = contextGroups.cloneArray()
        myClone.resolvers = resolvers.cloneDictionary()
        myClone.cachedResolvers = cachedResolvers.cloneDictionary()
        return myClone
    }
}

// MARK: Autoclosure

public extension Injector {
    
    // MARK: Transient
    
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addTransient<T>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addTransient(for: anyType, resolver: resolver)
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    func addTransient<T>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addTransient(for: anyTypes, resolver: resolver)
    }
    
    // MARK: Singleton
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addSingleton<T>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addSingleton(for: anyType, resolver: resolver)
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    func addSingleton<T>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addSingleton(for: anyTypes, resolver: resolver)
    }
    
    // MARK: Scoped
    
    /// provide scoped resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - context: scoped context, it will use Injector.sharedContext if not provided
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addScoped<T>(for anyType: Any.Type, in context: ImposeContext = Injector.sharedContext, _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyType, in: context, resolver: resolver)
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - context: scoped context, it will use Injector.sharedContext if not provided
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    func addScoped<T>(for anyTypes: [Any.Type], in context: ImposeContext = Injector.sharedContext, _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyTypes, in: context, resolver: resolver)
    }
}
