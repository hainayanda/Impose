//
//  Environment.swift
//  Impose
//
//  Created by Nayanda Haberty on 22/3/23.
//

import Foundation

public protocol Environmental {
    func environment(_ source: Environmental) -> Injector
}

private var environmentInjectorKey: String = "environmentInjectorKey"

extension Environmental {
    
    func getEnvironment() -> InjectResolver {
        guard let injector = objc_getAssociatedObject(self, &environmentInjectorKey) as? Injector else {
            let newInjector = Injector()
            setEnvironment(newInjector)
            return newInjector
        }
        return injector
    }
    
    func setEnvironment(_ resolver: InjectResolver) {
        objc_setAssociatedObject(self, &environmentInjectorKey, resolver, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public func environment(_ source: Environmental) -> Injector {
        let provider = source.getEnvironment()
        let resolver = Injector(parentProvider: provider)
        self.setEnvironment(resolver)
        Mirror(reflecting: self).setEnvironment(resolver)
        return resolver
    }
}
