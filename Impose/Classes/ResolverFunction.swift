//
//  ResolverFunction.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// get instance of the given type. It will throw ImposeError if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Throws: ImposeError
/// - Returns: instance resolved
public func tryInject<T>(_ type: T.Type = T.self, providedBy resolver: InjectContext? = nil) throws -> T {
    if let resolver = resolver {
        let instance: T
        if let resolverInstance = try? resolver.resolve(type) {
            instance = resolverInstance
        } else {
            instance = try Injector.shared.resolve(type)
        }
        // TODO: Remove this on next release
        if instance is Scopable {
            let reflection = Mirror(reflecting: instance)
            reflection.setEnvironment(resolver)
        }
        return instance
    }
    return try Injector.shared.resolve(type)
}

@available(*, deprecated, message: "Use Environmental instead")
/// get instance of the given type. It will throw ImposeError if fail
/// - Parameters:
///   - type: type of instance
///   - scopable: Scopable that will provide scopeInjector to resolve the instance
/// - Throws: ImposeError
/// - Returns: instance resolved
public func tryInject<T>(_ type: T.Type = T.self, scopedBy scopable: Scopable) throws -> T {
    try tryInject(type, providedBy: scopable.scopeContext)
}


/// get instance of the given type. It will use given closure if fail
/// - Parameters:
///   - type: type of instance
///   - resolve: closure resolver to call if inject fail
///   - injector: Injector that will resolve the instance
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type = T.self, providedBy resolver: InjectContext? = nil, ifFail resolve: () -> T) -> T {
    do {
        return try tryInject(type, providedBy: resolver)
    } catch {
        let instance = resolve()
        guard let resolver = resolver else {
            return instance
        }
        let reflection = Mirror(reflecting: instance)
        reflection.setEnvironment(resolver)
        return instance
    }
}

@available(*, deprecated, message: "Use Environmental instead")
/// get instance of the given type. It will use given closure if fail
/// - Parameters:
///   - type: type of instance
///   - scopable: Scopable that will provide scopeInjector to resolve the instance
///   - injector: Injector that will resolve the instance
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type = T.self, scopedBy scopable: Scopable, ifFail resolve: () -> T) -> T {
    inject(type, providedBy: scopable.scopeContext, ifFail: resolve)
}

/// get instance of the given type. It will use given autoclosure if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
///   - resolve: autoclosure resolver to call if inject fail
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type = T.self, providedBy resolver: InjectContext? = nil, ifFailUse resolve: @autoclosure () -> T) -> T {
    inject(type, providedBy: resolver, ifFail: resolve)
}

@available(*, deprecated, message: "Use Environmental instead")
/// get instance of the given type. It will use given autoclosure if fail
/// - Parameters:
///   - type: type of instance
///   - scopable: Scopable that will provide scopeInjector to resolve the instance
///   - resolve: autoclosure resolver to call if inject fail
/// - Returns:  instance resolved
public func inject<T>(_ type: T.Type = T.self, scopedBy scopable: Scopable, ifFailUse resolve: @autoclosure () -> T) -> T {
    inject(type, providedBy: scopable.scopeContext, ifFail: resolve)
}

/// get instance of the given type. It will throws fatal error if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Returns: instance resolved
public func inject<T>(_ type: T.Type = T.self, providedBy resolver: InjectContext? = nil) -> T {
    try! tryInject(type, providedBy: resolver)
}

@available(*, deprecated, message: "Use Environmental instead")
/// get instance of the given type. It will throws fatal error if fail
/// - Parameters:
///   - type: type of instance
///   - scopable: Scopable that will provide scopeInjector to resolve the instance
/// - Returns: instance resolved
public func inject<T>(_ type: T.Type = T.self, scopedBy scopable: Scopable) -> T {
    inject(type, providedBy: scopable.scopeContext)
}

/// get instance of the given type. it will return nil if fail
/// - Parameters:
///   - type: type of instance
///   - injector: Injector that will resolve the instance
/// - Returns: instance resolved if found and nil if not
public func injectIfProvided<T>(for type: T.Type = T.self, providedBy resolver: InjectContext? = nil) -> T? {
    try? tryInject(type, providedBy: resolver)
}

@available(*, deprecated, message: "Use Environmental instead")
/// get instance of the given type. it will return nil if fail
/// - Parameters:
///   - type: type of instance
///   - scopable: Scopable that will provide scopeInjector to resolve the instance
/// - Returns: instance resolved if found and nil if not
public func injectIfProvided<T>(for type: T.Type = T.self, scopedBy scopable: Scopable) -> T? {
    injectIfProvided(for: type, providedBy: scopable.scopeContext)
}
