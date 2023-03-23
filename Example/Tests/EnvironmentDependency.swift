//
//  EnvironmentDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 22/3/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Impose

class InjectEnv1 {
    @Injected
    var dependency: Dependency
}

class InjectEnv2 {
    @Injected
    var dependency: Dependency
    @Injected
    var childDependency: ChildDependency
}

class InjectEnv3 {
    @Injected
    var dependency: Dependency
    @Injected
    var childDependency: ChildDependency
    @Injected
    var grandChildDependency: GrandChildDependency
}
