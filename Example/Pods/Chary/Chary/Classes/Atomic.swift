//
//  Atomic.swift
//  Chary
//
//  Created by Nayanda Haberty on 01/06/22.
//

import Foundation

@propertyWrapper
/// Property marked by this property wrapper will set and get atomically
public final class Atomic<Wrapped> {
    var dispatcher: DispatchQueue
    var _wrappedValue: Wrapped
    public var wrappedValue: Wrapped {
        get {
            dispatcher.safeSync {
                _wrappedValue
            }
        }
        set {
            dispatcher.safeSync {
                _wrappedValue = newValue
            }
        }
    }
    
    /// The queue where the atomic run
    public var projectedValue: DispatchQueue {
        get {
            dispatcher
        }
        set {
            dispatcher = newValue
            newValue.registerDetection()
        }
    }
    
    public init(wrappedValue: Wrapped) {
        self.dispatcher = DispatchQueue(label: "Chary_Atomic_\(UUID().uuidString)")
        self._wrappedValue = wrappedValue
        self.dispatcher.registerDetection()
    }
    
    public init(_ dispatcher: DispatchQueue, wrappedValue: Wrapped) {
        self.dispatcher = dispatcher
        self._wrappedValue = wrappedValue
        dispatcher.registerDetection()
    }
    
}
