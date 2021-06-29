//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

typealias ImposerCollections = Dictionary<ImposerType, Imposer>

/// Injector class
public class Imposer {
    
    /// shared instance of primary imposer
    public static var shared: Imposer {
        imposer(of: .primary)
    }
    
    static var imposers: ImposerCollections = .init()
    
    var providers: ProviderMap = .init()
    var cachedNearest: ProviderMap = .init()
    var cachedFurthest: ProviderMap = .init()
    var cachedNearestCastable: ProviderMap = .init()
    var cachedFurthestCastable: ProviderMap = .init()
    
    /// Static function to get imposer of type
    /// If the imposer of type is not found, it will created a new one and return it
    /// - Parameter type: type of imposer
    /// - Returns: Imposer instance
    public static func imposer(of type: ImposerType) -> Imposer {
        guard let imposer = imposers[type] else {
            let imposer = Imposer()
            imposers[type] = imposer
            return imposer
        }
        return imposer
    }
    
    /// Static function to provide module injector
    /// It will automatically run module injector provide(for:) with its imposer type
    /// - Parameter moduleInjector: ModuleInjector
    public static func provide(using moduleInjector: ModuleInjector) {
        let imposer = imposer(of: moduleInjector.type)
        moduleInjector.provide(for: imposer)
    }
    
    /// Static function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public static func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance,_ provider: @escaping @autoclosure () -> T) {
        shared.impose(for: anyType, option: option, provider)
        
    }
    
    /// Static function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public static func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance,_ closureProvider: @escaping () -> T) {
        shared.impose(for: anyType, option: option, closureProvider)
    }
    
    /// Function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance,_ provider: @escaping @autoclosure () -> T) {
        providers.add(provider: option.createProvider(provider), for: anyType, includingOptional: true)
        clearCached()
    }
    
    /// Function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance,_ closureProvider: @escaping () -> T) {
        providers.add(provider: option.createProvider(closureProvider), for: anyType, includingOptional: true)
        clearCached()
    }
    
    func clearCached() {
        cachedNearest.removeAll()
        cachedFurthest.removeAll()
        cachedNearestCastable.removeAll()
        cachedFurthestCastable.removeAll()
    }
    
    func addCached<T>(for rules: InjectionRules, provider: Provider, for type: T.Type) {
        switch rules {
        case .nearest:
            cachedNearest.add(provider: provider, for: type)
        case .nearestAndCastable:
            cachedNearest.add(provider: provider, for: type)
        case .furthest:
            cachedFurthest.add(provider: provider, for: type)
        case .furthestAndCastable:
            cachedFurthestCastable.add(provider: provider, for: type)
        }
    }
    
    func imposedInstance<T>(of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearest) throws -> T {
        guard let instance: T = providers.get(for: anyType)?.getInstance() as? T
                ?? cachedInstance(of: anyType, rules: rules) else {
            return try compatibleInstance(of: anyType, use: rules)
        }
        return instance
    }
    
    func cachedInstance<T>(of anyType: T.Type, rules: InjectionRules) -> T? {
        switch rules {
        case .nearest:
            return cachedNearest.get(for: anyType)?.getInstance() as? T
        case .nearestAndCastable:
            return cachedNearestCastable.get(for: anyType)?.getInstance() as? T
        case .furthest:
            return cachedFurthest.get(for: anyType)?.getInstance() as? T
        case .furthestAndCastable:
            return cachedFurthestCastable.get(for: anyType)?.getInstance() as? T
        }
    }
    
    func compatibleInstance<T>(of anyType: T.Type, use rules: InjectionRules) throws -> T {
        let providers: [Provider]
        switch rules {
        case .furthest, .furthestAndCastable:
            providers = try furthestImposed(of: anyType, useCasting: rules.useCasting)
        case .nearest, .nearestAndCastable:
            providers = try nearestImposed(of: anyType, useCasting: rules.useCasting)
        }
        for provider in providers {
            guard let instance: T = provider.getInstance() as? T else {
                continue
            }
            addCached(for: rules, provider: provider, for: T.self)
            return instance
        }
        throw ImposeError(
            errorDescription: "Impose Error: fail when search for imposed instance",
            failureReason: "No compatible provider for \(String(describing:T.self))"
        )
    }
    
    func nearestImposed<T>(of anyType: T.Type, useCasting: Bool) throws -> [Provider] {
        var potentialProviders: [Provider] = []
        var nearest: Provider?
        for (_, provider) in providers {
            guard provider.isProvider(of: T.self) else {
                if provider.isPotentialProvider(of: T.self) {
                    potentialProviders.append(provider)
                } else if useCasting, provider.castableTo(type: T.self) {
                    potentialProviders.append(provider)
                }
                continue
            }
            if let found = nearest, provider.canBeProvided(by: found) {
                nearest = provider
            } else if nearest == nil {
                nearest = provider
            }
        }
        guard let provider = nearest else {
            return potentialProviders.sorted { $1.canBeProvided(by: $0) }
        }
        return [provider]
    }
    
    func furthestImposed<T>(of anyType: T.Type, useCasting: Bool) throws -> [Provider] {
        var potentialProviders: [Provider] = []
        var furthest: Provider?
        for (_, provider) in providers {
            guard provider.isProvider(of: T.self) else {
                if provider.isPotentialProvider(of: T.self) {
                    potentialProviders.append(provider)
                } else if useCasting, provider.castableTo(type: T.self) {
                    potentialProviders.append(provider)
                }
                continue
            }
            if let found = furthest, found.canBeProvided(by: provider) {
                furthest = provider
            } else if furthest == nil {
                furthest = provider
            }
        }
        guard let provider = furthest else {
            return potentialProviders.sorted { $0.canBeProvided(by: $1) }
        }
        return [provider]
    }
}

typealias ProviderMap = Dictionary<ObjectIdentifier, Provider>

extension Dictionary where Key == ObjectIdentifier, Value == Provider {
    
    func get<T>(for type: T.Type) -> Provider? {
        let identifier = ObjectIdentifier(type)
        return self[identifier]
    }
    
    mutating func add<T>(provider: Provider, for type: T.Type, includingOptional: Bool = false) {
        self[provider.identifier] = provider
        if includingOptional {
            let optionalProvider = provider.asProvider(for: T?.self)
            self[optionalProvider.identifier] = optionalProvider
        }
        clearInvalidProviders()
    }
    
    mutating func clearInvalidProviders() {
        for (key, provider) in self where !provider.isValid {
            self.removeValue(forKey: key)
        }
    }
    
}
