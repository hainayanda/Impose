//
//  ModuleProvider.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

/// Protocol to inject by module to the same imposer
public protocol ModuleProvider {
    
    /// This method will called when this class registered to Imposer
    /// - Parameter imposer: the imposer
    func provide(for imposer: Injector)
}
