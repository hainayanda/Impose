//
//  Scopable.swift
//  Impose
//
//  Created by Nayanda Haberty on 24/03/22.
//

import Foundation

@available(*, deprecated, message: "Use Environmental instead")
public protocol Scopable {
    var scopeContext: InjectContext { get }
    func scoped(by context: InjectContext)
    func scopedUsingSameContext(as scope: Scopable)
}

@available(*, deprecated, message: "Use Environmental instead")
public protocol ScopedInitiable {
    init(using context: InjectContext)
}

@available(*, deprecated, message: "Use Environmental instead")
public typealias ScopableInitiable = ScopedInitiable & Scopable

fileprivate var scopeContextKey: String = "scopeContextKey"

@available(*, deprecated, message: "Use Environmental instead")
public extension Scopable {
    
    internal var currentContext: InjectContext? {
        guard let context = objc_getAssociatedObject(self, &scopeContextKey) as? InjectContext else {
            return nil
        }
        return context
    }
    
    var scopeContext: InjectContext {
        guard let context = currentContext else {
            let newContext = Injector.shared.newScopedContext()
            scoped(by: newContext)
            return newContext
        }
        return context
    }
    
    func scoped(by context: InjectContext) {
        if currentContext === context { return }
        objc_setAssociatedObject(self, &scopeContextKey, context, .OBJC_ASSOCIATION_RETAIN)
        let reflection = Mirror(reflecting: self)
        reflection.setEnvironment(context)
    }
    
    func scopedUsingSameContext(as scope: Scopable) {
        scoped(by: scope.scopeContext)
    }
}
