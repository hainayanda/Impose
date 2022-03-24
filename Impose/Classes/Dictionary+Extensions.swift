//
//  Clonable.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Dictionary where Value == InstanceResolver {
    func withNoInstances() -> [Key: Value] {
        self.reduce([:]) { partialResult, pair in
            var result = partialResult
            result[pair.key] = pair.value.cloneWithNoInstance()
            return result
        }
    }
}
