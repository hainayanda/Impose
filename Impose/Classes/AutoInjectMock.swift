//
//  AutoMock.swift
//  Impose
//
//  Created by Nayanda Haberty on 22/2/23.
//

import Foundation

public protocol AutoInjectMock {
    static var registeredTypes: [Any.Type] { get }
    func inject(using injector: Injector)
}

public extension AutoInjectMock {
    
    static var injector: Injector { .shared }
    
    func inject(using injector: Injector) {
        injector.addSingleton(for: Self.registeredTypes, self)
    }
    
    @discardableResult
    func injected(using injector: Injector = .shared) -> Self {
        inject(using: injector)
        return self
    }
}
