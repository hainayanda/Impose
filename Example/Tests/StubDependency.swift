//
//  StubDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedInject {
    @Injected
    var dependency: Dependency
    @Injected
    var childDependency: ChildDependency
    @Injected
    var grandChildDependency: GrandChildDependency
}

public class InitInject {
    
    var dependency: Dependency
    var childDependency: ChildDependency
    var grandChildDependency: GrandChildDependency
    
    init(dependency: Dependency = inject(Dependency.self),
         someDependency: ChildDependency = inject(ChildDependency.self),
         someOtherDependency: GrandChildDependency = inject(GrandChildDependency.self)) {
        self.dependency = dependency
        self.childDependency = someDependency
        self.grandChildDependency = someOtherDependency
    }
}
