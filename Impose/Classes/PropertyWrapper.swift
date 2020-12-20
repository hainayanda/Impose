//
//  PropertyWrapper.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    public lazy var wrappedValue: T = inject(ifNoMatchUse: rules)
    let rules: InjectionRules
    public init(ifNoMatchUse rules: InjectionRules = .nearestType) {
        self.rules = rules
    }
}
