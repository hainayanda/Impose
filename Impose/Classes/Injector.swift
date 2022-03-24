//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

public typealias Imposer = Injector

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
    
    public func scopedInjector() -> InjectResolving {
        let resolver = InjectResolver()
        resolver.resolvers = scopedResolver.resolvers.withNoInstances()
        resolver.cachedResolvers = scopedResolver.resolvers.withNoInstances()
        return resolver
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
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addScoped<T>(for anyType: Any.Type, resolver: @escaping () -> T) {
        scopedResolver.resolvers[anyType] = SingleInstanceProvider(resolver: resolver)
        scopedResolver.cleanCachedAndGroup()
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addScoped<T>(for anyTypes: [Any.Type], resolver: @escaping () -> T) {
        let resolver = SingleInstanceProvider(resolver: resolver)
        for type in anyTypes {
            scopedResolver.resolvers[type] = resolver
        }
        scopedResolver.cleanCachedAndGroup()
    }
    
    // MARK: Resolve
    
    
    /// resolve instance from the given type. It will throws error if occured
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
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    func addScoped<T>(for anyType: Any.Type, _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyType, resolver: resolver)
    }
    
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again until context call release()
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    func addScoped<T>(for anyTypes: [Any.Type], _ resolver: @autoclosure @escaping () -> T) {
        addScoped(for: anyTypes, resolver: resolver)
    }
}
