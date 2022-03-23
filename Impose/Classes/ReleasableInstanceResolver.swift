//
//  ContextInstanceProvider.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

// MARK: ReleasableInstanceResolver protocol

protocol ReleasableInstanceResolver: InstanceResolver {
    func release()
}

// MARK: ContextInstanceProvider class

class ContextInstanceProvider<Instance>: InstanceProvider<Instance>, ReleasableInstanceResolver {
    
    var provider: () -> Instance
    var instance: Instance?
    
    init(provider: @escaping () -> Instance) {
        self.provider = provider
        super.init()
    }
    
    override func resolveInstance() -> Any {
        guard let instance = instance else {
            let newInstance = provider()
            self.instance = newInstance
            return newInstance
        }
        return instance
    }
    
    func release() {
        instance = nil
    }
}

// MARK: ContextGroup class

class ContextGroup {
    
    var groupId: AnyHashable
    var providers: [ReleasableInstanceResolver] = []
    
    weak private var _context: ImposeContext?
    
    var context: ImposeContext {
        guard let context = _context else {
            let newContext = ImposeContext(contextId: groupId, providerInContexts: providers)
            self._context = newContext
            return newContext
        }
        return context
    }
    
    public init(for context: ImposeContext) {
        self.groupId = context.contextId
        _context = context
    }
    
    func add(provider: ReleasableInstanceResolver) {
        self.providers.append(provider)
    }
    
    func remove(allNotIn providers: [TypeHashable: InstanceResolver]) {
        self.providers = self.providers.filter { myProvider in
            providers.values.contains { $0 === myProvider }
        }
        self._context?.providerInContexts = self.providers
    }
    
    func isGroup(of provider: InstanceResolver) -> Bool {
        guard let contextProvider = provider as? ReleasableInstanceResolver else {
            return false
        }
        return providers.contains { $0 === contextProvider }
    }
    
    func isGroup(of context: ImposeContext) -> Bool {
        guard let myContext = _context else {
            if context.contextId == groupId, context.providerInContexts.count == providers.count {
                for provider in providers {
                    if !context.providerInContexts.contains(where: {$0 === provider }) {
                        return false
                    }
                }
                return true
            }
            return false
        }
        return context === myContext
    }
}

// MARK: ImposeContext class

/// Context of Service Provider that can be used to release instance in the Service Provider
public class ImposeContext {
    
    var contextId: AnyHashable
    var providerInContexts: [ReleasableInstanceResolver]
    
    public init() {
        self.contextId = UUID().uuidString
        self.providerInContexts = []
    }
    
    init(contextId: AnyHashable, providerInContexts: [ReleasableInstanceResolver]) {
        self.contextId = contextId
        self.providerInContexts = providerInContexts
    }
    
    func add(provider: ReleasableInstanceResolver) {
        self.providerInContexts.append(provider)
    }
    
    deinit {
        release()
    }
    
    /// Release all the current instance in service providers in the same context
    public func release() {
        providerInContexts.forEach { $0.release() }
    }
}
