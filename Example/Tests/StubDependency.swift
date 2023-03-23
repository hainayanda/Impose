//
//  StubDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedInjectSub {
    
    @Injected
    var dependency: Dependency
    @Injected
    var childDependency: ChildDependency
    @Injected
    var grandChildDependency: GrandChildDependency
    
    public init() { }
}

public class WrappedInject: WrappedInjectSub {
    
    var sub: WrappedInjectSub
    
    public override init() {
        sub = .init()
    }
}

public class InitInject {
    
    var dependency: Dependency
    var childDependency: ChildDependency
    var grandChildDependency: GrandChildDependency
    
    init(dependency: Dependency = inject(),
         someDependency: ChildDependency = inject(),
         someOtherDependency: GrandChildDependency = inject()) {
        self.dependency = dependency
        self.childDependency = someDependency
        self.grandChildDependency = someOtherDependency
    }
}
