//
//  StubSafeDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedSafeInject: ScopableInitiable {
    
    @SafelyInjected
    var dependency: Dependency?
    @SafelyInjected
    var childDependency: ChildDependency?
    @SafelyInjected
    var grandChildDependency: GrandChildDependency?
    
    public required init(using context: InjectContext) {
        _dependency = .init(using: context)
        _childDependency = .init(using: context)
        _grandChildDependency = .init(using: context)
    }
}

public class InitSafeInject: ScopableInitiable {
    
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
    
    public required init(using context: InjectContext) {
        dependency = injectIfProvided(scopedBy: context)
        childDependency = injectIfProvided(scopedBy: context)
        grandChildDependency = injectIfProvided(scopedBy: context)
    }
}
