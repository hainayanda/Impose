//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation
import Chary

/// Injector class
public final class Injector: InjectResolver {
    
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
    
    // MARK: Public Properties
    
    /// Default init
    public override init() {
        super.init()
    }
    
    @discardableResult
    public func removeResolver<T>(of type: T.Type) -> Bool {
        sync {
            defer {
                cleanCachedAndRepopulate()
            }
            return mappedResolvers.removeValue(forKey: .init(metaType: type)) != nil
        }
    }
    
    // MARK: Transient
    
    @discardableResult
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addTransient<T>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            mappedResolvers[anyType] = FactoryInstanceProvider(queue: queue, resolver: resolver)
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    @discardableResult
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addTransient<T>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            let resolver = FactoryInstanceProvider(queue: queue, resolver: resolver)
            for type in anyTypes {
                mappedResolvers[type] = resolver
            }
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    // MARK: Singleton
    
    @discardableResult
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addSingleton<T>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            mappedResolvers[anyType] = SingleInstanceProvider(queue: queue, resolver: resolver)
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    @discardableResult
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addSingleton<T>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            let resolver = SingleInstanceProvider(queue: queue, resolver: resolver)
            for type in anyTypes {
                mappedResolvers[type] = resolver
            }
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    // MARK: Scoped
    
    // MARK: Weak
    
    @discardableResult
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func addWeakSingleton<T: AnyObject>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            mappedResolvers[anyType] = WeakSingleInstanceProvider(queue: queue, resolver: resolver)
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    @discardableResult
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func addWeakSingleton<T: AnyObject>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, resolver: @escaping () -> T) -> Self {
        sync {
            let resolver = WeakSingleInstanceProvider(queue: queue, resolver: resolver)
            for type in anyTypes {
                mappedResolvers[type] = resolver
            }
            cleanCachedAndRepopulate()
            return self
        }
    }
    
    // MARK: Resolve
    
    /// Resolve instance from the given type. It will throws error if occured.
    /// Time complexity will be O(1) and O(n) for worst case scenario.
    /// At the worst scenario, it will then cached the type and provider so at the next method call with the same type it will O(log n)
    /// - Parameter type: type
    /// - Throws: ImposeError
    /// - Returns: instance resolved
    @inlinable public override func resolve<T>(_ type: T.Type) throws -> T {
        return try super.resolve(type)
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
    
    @discardableResult
    /// provide transient resolver for the given type
    /// it will always create a new instance everytime resolver is asked for instance
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    @inlinable func addTransient<T>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addTransient(for: anyType, resolveOn: queue, resolver: resolver)
    }
    
    @discardableResult
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    @inlinable func addTransient<T>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addTransient(for: anyTypes, resolveOn: queue, resolver: resolver)
    }
    
    // MARK: Singleton
    
    @discardableResult
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    @inlinable func addSingleton<T>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addSingleton(for: anyType, resolveOn: queue, resolver: resolver)
    }
    
    @discardableResult
    /// provide singleton resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    @inlinable func addSingleton<T>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addSingleton(for: anyTypes, resolveOn: queue, resolver: resolver)
    }
    
    // MARK: Weak
    
    @discardableResult
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    @inlinable func addWeakSingleton<T: AnyObject>(for anyType: Any.Type, resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addWeakSingleton(for: anyType, resolveOn: queue, resolver: resolver)
    }
    
    @discardableResult
    /// provide scoped resolver for the given type
    /// it basically a singleton but stored in weak variable
    /// it will recreate a new instance once weak varibale is nil
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    @inlinable func addWeakSingleton<T: AnyObject>(for anyTypes: [Any.Type], resolveOn queue: DispatchQueue? = .current, _ resolver: @autoclosure @escaping () -> T) -> Self {
        addWeakSingleton(for: anyTypes, resolveOn: queue, resolver: resolver)
    }
}
