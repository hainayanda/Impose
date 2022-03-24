//
//  Mirror+Extensions.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Mirror {
    func setInjectedToBeScoped(by injector: InjectResolving) {
        children.forEach {
            if let property = $0.value as? InjectedProperty {
                property.scopedInjector = injector
            } else if let scopable = $0.value as? Scopable {
                scopable.scoped(by: injector)
            } else {
                let reflection = Mirror(reflecting: $0.value)
                reflection.setInjectedToBeScoped(by: injector)
            }
        }
    }
}
