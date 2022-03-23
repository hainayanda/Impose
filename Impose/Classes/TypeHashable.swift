//
//  TypeHashable.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

// MARK: TypeHashable struct

struct TypeHashable {
    let metaType: Any.Type
}

extension TypeHashable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(metaType))
    }
    
    static func == (lhs: TypeHashable, rhs: TypeHashable) -> Bool {
        lhs.metaType == rhs.metaType
    }
}

// MARK: Dictionary extensions

extension Dictionary where Key == TypeHashable {
    subscript(type: Any.Type) -> Value? {
        get {
            self[TypeHashable(metaType: type)]
        }
        set {
            self[TypeHashable(metaType: type)] = newValue
        }
    }
}
