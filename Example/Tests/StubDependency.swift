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
    @Injected(ifNoMatchUse: .furthestType)
    var dependency: Dependency
    @Injected(ifNoMatchUse: .furthestType)
    var someDependency: SomeDependency
    @Injected(ifNoMatchUse: .furthestType)
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
    
    init(dependency: Dependency = inject(ifNoMatchUse: .furthestType),
         someDependency: SomeDependency = inject(of: SomeDependency.self, ifNoMatchUse: .furthestType),
         someOtherUpperDependency: SomeOtherUpperDependency = inject(ifNoMatchUse: .furthestType)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherUpperDependency = someOtherUpperDependency
    }
}
