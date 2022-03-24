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
    
    var resolver: () -> Instance
    var instance: Instance?
    
    init(resolver: @escaping () -> Instance) {
        self.resolver = resolver
        super.init()
    }
    
    override func resolveInstance() -> Any {
        guard let instance = instance else {
            let newInstance = resolver()
            self.instance = newInstance
            return newInstance
        }
        return instance
    }
    
    override func clone() -> Any {
        ContextInstanceProvider(resolver: resolver)
    }
    
    func release() {
        instance = nil
    }
}

// MARK: ContextGroup class

class ContextGroup: Clonable {
    
    var groupId: AnyHashable
    var resolvers: [ReleasableInstanceResolver] = []
    
    weak private var _context: ImposeContext?
    
    var context: ImposeContext {
        guard let context = _context else {
            let newContext = ImposeContext(contextId: groupId, resolverInContexts: resolvers)
            self._context = newContext
            return newContext
        }
        return context
    }
    
    public init(for context: ImposeContext) {
        self.groupId = context.contextId
        _context = context
    }
    
    init(with groupId: AnyHashable) {
        self.groupId = groupId
    }
    
    func clone() -> Any {
        ContextGroup(with: groupId)
    }
    
    func add(resolver: ReleasableInstanceResolver) {
        self.resolvers.append(resolver)
    }
    
    func remove(allNotIn resolvers: [TypeHashable: InstanceResolver]) {
        self.resolvers = self.resolvers.filter { myProvider in
            resolvers.values.contains { $0 === myProvider }
        }
        self._context?.resolverInContexts = self.resolvers
    }
    
    func isGroup(of resolver: InstanceResolver) -> Bool {
        guard let contextProvider = resolver as? ReleasableInstanceResolver else {
            return false
        }
        return resolvers.contains { $0 === contextProvider }
    }
    
    func isGroup(of context: ImposeContext) -> Bool {
        guard let myContext = _context else {
            guard context.contextId == groupId,
                  context.resolverInContexts.count == resolvers.count else {
                return false
            }
            for resolver in resolvers {
                if !context.resolverInContexts.contains(where: {$0 === resolver }) {
                    return false
                }
            }
            return true
        }
        return context === myContext
    }
}

// MARK: ImposeContext class

/// Context of Service Provider that can be used to release instance in the Service Provider
public class ImposeContext {
    
    var contextId: AnyHashable
    var resolverInContexts: [ReleasableInstanceResolver]
    
    public init() {
        self.contextId = UUID().uuidString
        self.resolverInContexts = []
    }
    
    init(contextId: AnyHashable, resolverInContexts: [ReleasableInstanceResolver]) {
        self.contextId = contextId
        self.resolverInContexts = resolverInContexts
    }
    
    func add(resolver: ReleasableInstanceResolver) {
        self.resolverInContexts.append(resolver)
    }
    
    deinit {
        release()
    }
    
    /// Release all the current instance in service resolvers in the same context
    public func release() {
        resolverInContexts.forEach { $0.release() }
    }
}
