//
//  Scopable.swift
//  Impose
//
//  Created by Nayanda Haberty on 24/03/22.
//

import Foundation

public protocol Scopable {
    var scopeInjector: InjectResolving { get }
    func scoped(by injector: InjectResolving)
    func scoped(from scope: Scopable)
    func applyAsRootScopedInjection()
}

fileprivate var scopeInjectorKey: String = "scopeInjectorKey"

public extension Scopable {
    internal var currentInjector: InjectResolving? {
        guard let injector = objc_getAssociatedObject(self, &scopeInjectorKey) as? InjectResolving else {
            return nil
        }
        return injector
    }
    var scopeInjector: InjectResolving {
        guard let injector = currentInjector else {
            let newInjector = Injector.shared.scopedInjector()
            scoped(by: newInjector)
            return newInjector
        }
        return injector
    }
    
    func scoped(by injector: InjectResolving) {
        if currentInjector === injector { return }
        objc_setAssociatedObject(self, &scopeInjectorKey, injector, .OBJC_ASSOCIATION_RETAIN)
        let reflection = Mirror(reflecting: self)
        reflection.setInjectedToBeScoped(by: injector)
    }
    
    func scoped(from scope: Scopable) {
        scoped(by: scope.scopeInjector)
    }
    
    func applyAsRootScopedInjection() {
        scoped(by: Injector.shared.scopedInjector())
    }
}
