//
//  Model.swift
//  Impose
//
//  Created by Nayanda Haberty on 20/12/20.
//

import Foundation

/// Error object generated from Impose
public struct ImposeError: LocalizedError {
    
    /// Description of error
    public let errorDescription: String?
    
    /// Reason of failure
    public let failureReason: String?
    
    init(errorDescription: String, failureReason: String? = nil) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
    }
}
