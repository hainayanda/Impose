//
//  Mirror+Extensions.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Mirror {
    func setInjectedToBeScoped(by injector: Injector) {
        children.forEach {
            guard let property = $0.value as? InjectedProperty else {
                return
            }
            property.scopedInjector = injector
        }
    }
}

/// inject all @injected property in given object and its property using same injector
/// - Parameters:
///   - object: any object
///   - injector: injector
public func inject(_ object: Any, with injector: Injector) {
    let reflection = Mirror(reflecting: object)
    reflection.setInjectedToBeScoped(by: injector)
}
