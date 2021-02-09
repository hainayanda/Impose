//
//  Imposer.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

/// Injector class
public class Imposer {
    
    /// shared instance of Imposer
    public static var shared: Imposer = .init()
    
    var providers: [Provider] = []
    
    /// Static function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public static func impose<T>(for anyType: T.Type, option: InjectOption = .singleton,_ provider: @escaping @autoclosure () -> T) {
        shared.providers.removeAll { $0.isSameType(of: anyType) }
        shared.providers.append(InjectProvider(option: option, provider))
    }
    
    /// Function to provide assosiated dependency for some Type
    /// - Parameters:
    ///   - anyType: Type of instance
    ///   - option: Option of how to provide the dependency
    ///   - provider: The provider
    public func impose<T>(for anyType: T.Type, option: InjectOption = .singleton,_ provider: @escaping @autoclosure () -> T) {
        providers.removeAll { $0.isSameType(of: anyType) }
        providers.append(InjectProvider(option: option, provider))
    }
    
    func imposedInstance<T>(of anyType: T.Type, ifNoMatchUse rules: InjectionRules = .nearestType) throws -> T {
        let providers: [Provider]
        switch rules {
        case .furthestType:
            providers = try furthestImposed(of: anyType)
        default:
            providers = try nearestImposed(of: anyType)
        }
        for provider in providers {
            guard let instance: T = provider.getInstance() as? T else {
                continue
            }
            return instance
        }
        throw ImposeError(
            errorDescription: "Impose Error: fail when search for imposed instance",
            failureReason: "No compatible provider for \(String(describing:T.self))"
        )
    }
    
    func nearestImposed<T>(of anyType: T.Type) throws -> [Provider] {
        var potentialProviders: [Provider] = []
        var nearest: Provider?
        for provider in providers {
            guard provider.isProvider(of: T.self) else {
                if provider.isPotentialProvider(of: T.self) {
                    potentialProviders.append(provider)
                } else if provider.castableTo(type: T.self) {
                    potentialProviders.append(provider)
                }
                continue
            }
            if provider.isSameType(of: anyType) {
                return [provider]
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
    
    func furthestImposed<T>(of anyType: T.Type) throws -> [Provider] {
        var potentialProviders: [Provider] = []
        var furthest: Provider?
        for provider in providers {
            guard provider.isProvider(of: T.self) else {
                if provider.isPotentialProvider(of: T.self) {
                    potentialProviders.append(provider)
                } else if provider.castableTo(type: T.self) {
                    potentialProviders.append(provider)
                }
                continue
            }
            if provider.isSameType(of: anyType) {
                return [provider]
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
