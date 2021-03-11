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
    @UnforceInjected(ifNoMatchUse: .furthest)
    var dependency: Dependency?
    @UnforceInjected(ifNoMatchUse: .furthest)
    var someDependency: SomeDependency?
    @UnforceInjected(ifNoMatchUse: .furthest)
    var someOtherUpperDependency: SomeOtherUpperDependency?
}

public class InitUnforceInject {
    
    var dependency: Dependency?
    var someDependency: SomeDependency?
    var someOtherDependency: SomeOtherDependency?
    
    init(dependency: Dependency? = try? tryInject(),
         someDependency: SomeDependency? = unforceInject(),
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
    
    init(dependency: Dependency? = unforceInject(ifNoMatchUse: .furthest),
         someDependency: SomeDependency? = unforceInject(ifNoMatchUse: .furthest),
         someOtherUpperDependency: SomeOtherUpperDependency? = unforceInject(ifNoMatchUse: .furthest)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherUpperDependency = someOtherUpperDependency
    }
}

