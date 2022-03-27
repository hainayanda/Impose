//
//  ImposerCompat.swift
//  Impose
//
//  Created by Nayanda Haberty on 27/03/22.
//

import Foundation

public typealias Imposer = Injector

public typealias UnforceInjected = SafelyInjected

public enum InjectOption {
    case singleInstance
    case closureBased
}

public extension Imposer {
    @available(*, deprecated, message: "Use addSingleton or addTransient instead")
    func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance, _ provider: @escaping @autoclosure () -> T) {
        switch option {
        case .singleInstance:
            addSingleton(for: anyType, provider)
        case .closureBased:
            addTransient(for: anyType, provider)
        }
    }
    
    @available(*, deprecated, message: "Use addSingleton or addTransient instead")
    func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance, _ closureProvider: @escaping () -> T) {
        switch option {
        case .singleInstance:
            addSingleton(for: anyType, closureProvider)
        case .closureBased:
            addTransient(for: anyType, closureProvider)
        }
    }
    
    @available(*, deprecated, message: "Use shared.addSingleton or shared.addTransient instead")
    static func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance, _ provider: @escaping @autoclosure () -> T) {
        switch option {
        case .singleInstance:
            shared.addSingleton(for: anyType, provider)
        case .closureBased:
            shared.addTransient(for: anyType, provider)
        }
    }
    
    @available(*, deprecated, message: "Use shared.addSingleton or shared.addTransient instead")
    static func impose<T>(for anyType: T.Type, option: InjectOption = .singleInstance, _ closureProvider: @escaping () -> T) {
        switch option {
        case .singleInstance:
            shared.addSingleton(for: anyType, closureProvider)
        case .closureBased:
            shared.addTransient(for: anyType, closureProvider)
        }
    }
}
