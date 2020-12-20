//
//  StubUnforceDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Impose

public class WrappedUnforceInject {
    @UnforceInjected
    var dependency: Dependency?
    @UnforceInjected
    var someDependency: SomeDependency?
    @UnforceInjected
    var someOtherDependency: SomeOtherDependency?
}

public class OtherWrappedUnforceInject {
    @UnforceInjected(ifNoMatchUse: .furthestType)
    var dependency: Dependency?
    @UnforceInjected(ifNoMatchUse: .furthestType)
    var someDependency: SomeDependency?
    @UnforceInjected(ifNoMatchUse: .furthestType)
    var someOtherUpperDependency: SomeOtherUpperDependency?
}

public class InitUnforceInject {
    
    var dependency: Dependency?
    var someDependency: SomeDependency?
    var someOtherDependency: SomeOtherDependency?
    
    init(dependency: Dependency? = try? tryInject(),
         someDependency: SomeDependency? = unforceInject(of: SomeDependency.self),
         someOtherDependency: SomeOtherDependency? = try? tryInject(of: SomeOtherDependency.self)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherDependency = someOtherDependency
    }
}

public class OtherInitUnforceInject {
    
    var dependency: Dependency?
    var someDependency: SomeDependency?
    var someOtherUpperDependency: SomeOtherUpperDependency?
    
    init(dependency: Dependency? = try? tryInject(ifNoMatchUse: .furthestType),
         someDependency: SomeDependency? = unforceInject(of: SomeDependency.self, ifNoMatchUse: .furthestType),
         someOtherUpperDependency: SomeOtherUpperDependency? = try? tryInject(of: SomeOtherUpperDependency.self, ifNoMatchUse: .furthestType)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherUpperDependency = someOtherUpperDependency
    }
}

