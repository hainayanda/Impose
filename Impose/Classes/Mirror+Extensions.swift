//
//  Mirror+Extensions.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Mirror {
    func setInjectedToBeScoped(by context: InjectContext) {
        children.forEach {
            guard let property = $0.value as? ScopeInjectable else { return }
            property.applyScope(by: context)
        }
        self.superclassMirror?.setInjectedToBeScoped(by: context)
    }
}
