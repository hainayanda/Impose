//
//  Dependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

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
