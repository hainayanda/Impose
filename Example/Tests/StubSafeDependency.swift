//
//  StubSafeDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedSafeInject {
    
    @SafelyInjected
    var dependency: Dependency?
    @SafelyInjected
    var childDependency: ChildDependency?
    @SafelyInjected
    var grandChildDependency: GrandChildDependency?
    
    public init() { }
}

public class InitSafeInject {
    
    var dependency: Dependency?
    var childDependency: ChildDependency?
    var grandChildDependency: GrandChildDependency?
    
    init(dependency: Dependency? = injectIfProvided(),
         someDependency: ChildDependency? = injectIfProvided(),
         someOtherDependency: GrandChildDependency? = injectIfProvided()) {
        self.dependency = dependency
        self.childDependency = someDependency
        self.grandChildDependency = someOtherDependency
    }
}
