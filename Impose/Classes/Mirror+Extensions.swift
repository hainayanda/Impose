//
//  Mirror+Extensions.swift
//  Impose
//
//  Created by Nayanda Haberty on 23/03/22.
//

import Foundation

extension Mirror {
    func setEnvironment(_ context: InjectContext) {
        children.forEach {
            guard let property = $0.value as? EnvironmentInjectable else { return }
            property.provided(by: context)
        }
        self.superclassMirror?.setEnvironment(context)
    }
}
