//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// Injector class
public class Injector: InjectResolver {
    
    // MARK: Public Static
    
    /// shared instance of active Injector
    public static var shared: Injector {
        customInjector ?? defaultInjector
    }
    
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
    lazy var scopedResolver: InjectResolver = InjectResolver()
    
    // MARK: Public Properties
    
    /// Default init
    public override init() {
        super.init()
    }
    
    // MARK: Scoped
    
    public func newScopedContext() -> InjectContext {
        let context = InjectResolver()
        let mappedResolvers = scopedResolver.mappedResolvers.withNoInstances()
        let allResolvers: [InstanceResolver] = mappedResolvers.uniqueValueInstances
        context.mappedResolvers = mappedResolvers
        context.resolvers = allResolvers
        return context
    }
    
    // MARK: Transient
    
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addTransient<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        mappedResolvers[anyType] = FactoryInstanceProvider(resolver: resolver)
        cleanCachedAndRepopulate()
    }
    
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addTransient<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = FactoryInstanceProvider(resolver: resolver)
        for type in anyTypes {
            mappedResolvers[type] = resolver
        }
        cleanCachedAndRepopulate()
    }
    
    // MARK: Singleton
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addSingleton<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        mappedResolvers[anyType] = SingleInstanceProvider(resolver: resolver)
        cleanCachedAndRepopulate()
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addSingleton<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = SingleInstanceProvider(resolver: resolver)
        for type in anyTypes {
            mappedResolvers[type] = resolver
        }
        cleanCachedAndRepopulate()
    }
    
    // MARK: Scoped
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but in scoped manner.
    /// it will reused the same instance in same scoped
    /// if there is no scope, then it will act like a singleton
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addScoped<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        scopedResolver.mappedResolvers[anyType] = SingleInstanceProvider(resolver: resolver)
        scopedResolver.cleanCachedAndRepopulate()
    }
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but in scoped manner.
    /// it will reused the same instance in same scoped
    /// if there is no scope, then it will act like a singleton
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addScoped<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = SingleInstanceProvider(resolver: resolver)
        for type in anyTypes {
            scopedResolver.mappedResolvers[type] = resolver
        }
        scopedResolver.cleanCachedAndRepopulate()
    }
    
    // MARK: Weak
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addWeakSingleton<T: AnyObject>(for anyType: Any.Type, resolver: @escaping () -> T) {
        mappedResolvers[anyType] = WeakSingleInstanceProvider(resolver: resolver)
        cleanCachedAndRepopulate()
    }
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addWeakSingleton<T: AnyObject>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = WeakSingleInstanceProvider(resolver: resolver)
        for type in anyTypes {
            mappedResolvers[type] = resolver
        }
        cleanCachedAndRepopulate()
    }
    
    // MARK: Resolve
    
    /// Resolve instance from the given type. It will throws error if occured.
    /// Time complexity will be O(log n) and O(n) for worst case scenario.
    /// At the worst scenario, it will then cached the type and provider so at the next method call with the same type it will O(log n)
    /// - Parameter type: type
    /// - Throws: ImposeError
    /// - Returns: instance resolved
    public override func resolve<T>(_ type: T.Type) throws -> T {
        do {
            return try super.resolve(type)
        } catch {
            return try scopedResolver.resolve(type)
        }
    }
    
    // MARK: Module
    
    /// It will automatically run module injector provide(for:) with its service imposer
    /// - Parameter moduleProvider: the ModuleProvider
    public func provide(using moduleProvider: ModuleProvider) {
        moduleProvider.provide(for: self)
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
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addSingleton<T>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addSingleton(for: anyType, resolver: resolver)
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    func addSingleton<T>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addSingleton(for: anyTypes, resolver: resolver)
    }
    
    // MARK: Scoped
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but in scoped manner.
    /// it will reused the same instance in same scoped
    /// if there is no scope, then it will act like a singleton
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addScoped<T>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyType, resolver: resolver)
    }
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but in scoped manner.
    /// it will reused the same instance in same scoped
    /// if there is no scope, then it will act like a singleton
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    func addScoped<T>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyTypes, resolver: resolver)
    }
    
    // MARK: Weak
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    func addWeakSingleton<T: AnyObject>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addWeakSingleton(for: anyType, resolver: resolver)
    }
    
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    func addWeakSingleton<T: AnyObject>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addWeakSingleton(for: anyTypes, resolver: resolver)
    }
}
