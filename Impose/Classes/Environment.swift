//
//  Environment.swift
//  Impose
//
//  Created by Nayanda Haberty on 22/3/23.
//

import Foundation

final public class Environment: InjectResolver {
    
    @inlinable public override init() {
        super.init()
    }
    
    init(source: Environment) {
        super.init()
        self.resolvers = source.resolvers
        self.mappedResolvers = source.mappedResolvers
        self.cachedMappedResolvers = source.cachedMappedResolvers
    }
    
    init(extractingFrom object: AnyObject) {
        super.init()
        self.mappedResolvers = Mirror(reflecting: object).extractManuallyAssignedProvider()
        self.resolvers = self.mappedResolvers.uniqueValueInstances
        self.cachedMappedResolvers = [:]
    }
    
    func add(mappedResolvers: [TypeHashable: InstanceResolver]) {
        for (type, resolver) in mappedResolvers {
            self.mappedResolvers[type] = resolver
        }
        cleanCachedAndRepopulate()
    }
    
    @discardableResult
    /// provide environment resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again in same enviroment
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: closure that will be called to create instance if asked for given type
    public func inject<T>(
        for anyType: Any.Type,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> T) -> Self {
            sync {
                mappedResolvers[anyType] = SingleInstanceProvider(queue: queue, resolver: resolver)
                cleanCachedAndRepopulate()
                return self
            }
        }
    
    @discardableResult
    /// provide environment resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again in same enviroment
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: closure that will be called to create instance if asked for given types
    public func inject<T>(
        for anyTypes: [Any.Type],
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> T) -> Self {
            sync {
                let resolver = SingleInstanceProvider(queue: queue, resolver: resolver)
                for type in anyTypes {
                    mappedResolvers[type] = resolver
                }
                cleanCachedAndRepopulate()
                return self
            }
        }
}

extension Environment {
    
    @discardableResult
    /// provide environment resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again in same enviroment
    /// - Parameters:
    ///   - anyType: type of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given type
    @inlinable public func inject<T>(
        for anyType: Any.Type,
        resolveOn queue: DispatchQueue? = nil,
        _ resolver: @autoclosure @escaping () -> T) -> Self {
            inject(for: anyType, resolveOn: queue, resolver: resolver)
        }
    
    @discardableResult
    /// provide environment resolver for the given type
    /// it will just create an instance once and reused it if asked to resolve again in same enviroment
    /// - Parameters:
    ///   - anyTypes: types of resolver
    ///   - resolver: autoclosure that will be called to create instance if asked for given types
    @inlinable public func inject<T>(
        for anyTypes: [Any.Type],
        resolveOn queue: DispatchQueue? = nil,
        _ resolver: @autoclosure @escaping () -> T) -> Self {
            inject(for: anyTypes, resolveOn: queue, resolver: resolver)
        }
}

private var environmentInjectorKey: UnsafeMutableRawPointer = malloc(1)

extension Environment {
    
    /// Create new Environment for the given object with inital dependencies
    /// from the source Environment if it have one
    /// that used as primary source of Dependencies for Injected propertyWrapper.
    /// - Parameters:
    ///   - source: source object
    ///   - object: any object
    /// - Returns: Environment object
    public static func fromObject(_ source: AnyObject, for object: AnyObject) -> Environment {
        let manualProviders = Mirror(reflecting: source).extractManuallyAssignedProvider()
        guard let sourceEnvironment = objc_getAssociatedObject(source, &environmentInjectorKey) as? Environment else {
            let environment = forObject(object)
            environment.add(mappedResolvers: manualProviders)
            return environment
        }
        let newEnvironment = Environment(source: sourceEnvironment)
        newEnvironment.add(mappedResolvers: manualProviders)
        objc_setAssociatedObject(object, &environmentInjectorKey, newEnvironment, .OBJC_ASSOCIATION_RETAIN)
        Mirror(reflecting: object).setInjectContext(newEnvironment)
        return newEnvironment
    }
    
    /// Get the Environment for the given object that used as primary source of Dependencies for Injected.
    /// - Parameter object: any object
    /// - Returns: Environment object
    public static func forObject(_ object: AnyObject) -> Environment {
        guard let currentEnvironment = objc_getAssociatedObject(object, &environmentInjectorKey) as? Environment else {
            let newEnvironment = Environment(extractingFrom: object)
            objc_setAssociatedObject(object, &environmentInjectorKey, newEnvironment, .OBJC_ASSOCIATION_RETAIN)
            Mirror(reflecting: object).setInjectContext(newEnvironment)
            return newEnvironment
        }
        return currentEnvironment
    }
}
