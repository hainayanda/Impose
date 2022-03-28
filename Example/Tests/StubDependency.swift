//
//  StubDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedInjectSub: ScopableInitiable {
    
    @Injected
    var dependency: Dependency
    @Injected
    var childDependency: ChildDependency
    @Injected
    var grandChildDependency: GrandChildDependency
    
    public required init(using context: InjectContext) {
        scoped(by: context)
    }
    
    public init() { }
}

public class WrappedInject: WrappedInjectSub {
    
    @Scoped
    var sub: WrappedInjectSub
    
    public required init(using context: InjectContext) {
        sub = .init()
        super.init(using: context)
    }
    
    public override init() {
        sub = .init()
        super.init()
    }
}

public class InitInject: ScopableInitiable {
    
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
    
    public required init(using context: InjectContext) {
        dependency = inject(scopedBy: context)
        childDependency = inject(scopedBy: context)
        grandChildDependency = inject(scopedBy: context)
    }
}
