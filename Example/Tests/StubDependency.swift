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

protocol Dependency {
    func explainMyself() -> String
}

class SomeDependency: Dependency {
    func explainMyself() -> String {
        return "I am SomeDependency and Injected"
    }
}

class SomeOtherDependency: SomeDependency {
    override func explainMyself() -> String {
        return "I am SomeOtherDependency and Injected"
    }
}

class SomeOtherUpperDependency: SomeOtherDependency {
    override func explainMyself() -> String {
        return "I am SomeOtherUpperDependency and Injected"
    }
}
