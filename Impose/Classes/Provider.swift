//
//  Provider.swift
//  Impose
//
//  Created by Nayanda Haberty on 11/03/21.
//

import Foundation

protocol Provider: class {
    var identifier: ObjectIdentifier { get }
    var isValid: Bool { get }
    func canBeProvided(by otherProvider: Provider) -> Bool
    func isProvider<TypeToProvide>(of anyType: TypeToProvide.Type) -> Bool
    func castableTo<TypeToProvide>(type: TypeToProvide.Type) -> Bool
    func isPotentialProvider(of anyType: Any.Type) -> Bool
    func getInstance() -> Any
    func asProvider<TypeToProvide>(for anyType: TypeToProvide.Type) -> Provider
}

extension Provider {
    func asProvider<TypeToProvide>(for anyType: TypeToProvide.Type) -> Provider {
        ReferenceProvider(realProvider: self, for: TypeToProvide.self)
    }
}

class BaseProvider<T>: Provider {
    
    var identifier: ObjectIdentifier { ObjectIdentifier(T.self) }
    
    var isValid: Bool { false }
    
    func canBeProvided(by otherProvider: Provider) -> Bool {
        otherProvider.isProvider(of: T.self)
    }
    
    func isProvider<TypeToProvide>(of anyType: TypeToProvide.Type) -> Bool {
        T.self is TypeToProvide.Type
    }
    
    func castableTo<TypeToProvide>(type: TypeToProvide.Type) -> Bool {
        fatalError("get castableTo should be overridden")
    }
    
    func isPotentialProvider(of anyType: Any.Type) -> Bool {
        anyType is T.Type
    }
    
    func getInstance() -> Any {
        fatalError("get instance should be overridden")
    }
}

class InjectProvider<T>: BaseProvider<T> {
    
    var provider: () -> T
    lazy var providedInstance: T = provider()
    var option: InjectOption
    
    override var isValid: Bool { true }
    
    init(option: InjectOption, _ provider: @escaping () -> T) {
        self.provider = provider
        self.option = option
    }
    
    override func castableTo<TypeToProvide>(type: TypeToProvide.Type) -> Bool {
        providedInstance as? TypeToProvide != nil
    }
    
    override func getInstance() -> Any {
        switch option {
        case .singleInstance:
            return providedInstance
        default:
            return provider()
        }
    }
}

class ReferenceProvider<T>: BaseProvider<T> {
    weak var realProvider: Provider?
    
    override var isValid: Bool { realProvider?.isValid ?? false }
    
    init(realProvider: Provider, for type: T.Type) {
        self.realProvider = realProvider
    }
    
    override func castableTo<TypeToProvide>(type: TypeToProvide.Type) -> Bool {
        realProvider?.castableTo(type: type) ?? false
    }
    
    override func getInstance() -> Any {
        realProvider?.getInstance() as Any
    }
}
