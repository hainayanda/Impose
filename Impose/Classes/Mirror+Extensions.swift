//
//  Mirror+Extensions.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Mirror {
    func setInjectContext(_ context: InjectContext) {
        children.forEach {
            guard let property = $0.value as? EnvironmentInjectable else { return }
            property.provided(by: context)
        }
        self.superclassMirror?.setInjectContext(context)
    }
    
    func extractManuallyAssignedProvider() -> [TypeHashable: InstanceResolver] {
        let resolvers = children.compactMap { $0.value as? ManualAssignedProviderExtractable }
            .compactMap { $0.manualAssignedProvider() }
        var superProviders = self.superclassMirror?.extractManuallyAssignedProvider() ?? [:]
        for (type, provider) in resolvers {
            superProviders[type] = provider
        }
        return superProviders
    }
}
