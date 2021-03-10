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
    var someDependency: SomeDependency
    @Injected
    var someOtherDependency: SomeOtherDependency
}

public class OtherWrappedInject {
    @Injected(ifNoMatchUse: .furthest)
    var dependency: Dependency
    @Injected(ifNoMatchUse: .furthest)
    var someDependency: SomeDependency
    @Injected(ifNoMatchUse: .furthest)
    var someOtherUpperDependency: SomeOtherUpperDependency
}

public class InitInject {
    
    var dependency: Dependency
    var someDependency: SomeDependency
    var someOtherDependency: SomeOtherDependency
    
    init(dependency: Dependency = inject(),
         someDependency: SomeDependency = inject(of: SomeDependency.self),
         someOtherDependency: SomeOtherDependency = inject()) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherDependency = someOtherDependency
    }
}

public class OtherInitInject {
    
    var dependency: Dependency
    var someDependency: SomeDependency
    var someOtherUpperDependency: SomeOtherUpperDependency
    
    init(dependency: Dependency = inject(ifNoMatchUse: .furthest),
         someDependency: SomeDependency = inject(of: SomeDependency.self, ifNoMatchUse: .furthest),
         someOtherUpperDependency: SomeOtherUpperDependency = inject(ifNoMatchUse: .furthest)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherUpperDependency = someOtherUpperDependency
    }
}
