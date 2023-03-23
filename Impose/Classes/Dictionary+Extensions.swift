//
//  Clonable.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Dictionary where Value == InstanceResolver {
    
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
