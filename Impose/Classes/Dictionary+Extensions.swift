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
    
    var uniqueValueInstances: [Value] {
        self.reduce([]) { partialResult, pair in
            let extracted = partialResult.contains { $0 === pair.value }
            guard !extracted else { return partialResult }
            var result = partialResult
            result.append(pair.value)
            return result
        }
    }
}
