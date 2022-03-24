//
//  StubSafeDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedSafeInject: Scopable {
    @SafelyInjected
    var dependency: Dependency?
    @SafelyInjected
    var childDependency: ChildDependency?
    @SafelyInjected
    var grandChildDependency: GrandChildDependency?
}

public class InitSafeInject {
    
    var dependency: Dependency?
    var childDependency: ChildDependency?
    var grandChildDependency: GrandChildDependency?
    
    init(dependency: Dependency? = injectIfProvided(for: Dependency.self),
         someDependency: ChildDependency? = injectIfProvided(for: ChildDependency.self),
         someOtherDependency: GrandChildDependency? = injectIfProvided(for: GrandChildDependency.self)) {
        self.dependency = dependency
        self.childDependency = someDependency
        self.grandChildDependency = someOtherDependency
    }
}
