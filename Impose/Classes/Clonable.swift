//
//  Clonable.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

protocol Clonable {
    func clone() -> Any
}

extension Array: Clonable where Element: Clonable {
    func clone() -> Any {
        self.compactMap { $0.clone() as? Element }
    }
    
    func cloneArray() -> [Element] {
        clone() as? [Element] ?? []
    }
}

extension Array where Element == InstanceResolver {
    
    func cloneArray() -> [Element] {
        self.compactMap { $0.clone() as? Element }
    }
}

extension Dictionary: Clonable where Value: Clonable {
    func clone() -> Any {
        self.reduce([:]) { partialResult, pair in
            var result = partialResult
            result[pair.key] = pair.value.clone() as? Value
            return result
        }
    }
    
    func cloneDictionary() -> [Key: Value] {
        clone() as? [Key: Value] ?? [:]
    }
}

extension Dictionary where Value == InstanceResolver {
    func cloneDictionary() -> [Key: Value] {
        self.reduce([:]) { partialResult, pair in
            var result = partialResult
            result[pair.key] = pair.value.clone() as? Value
            return result
        }
    }
}
