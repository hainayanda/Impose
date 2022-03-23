//
//  Dependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

protocol Dependency: AnyObject {
    func explainMyself() -> String
}

class ChildDependency: Dependency {
    func explainMyself() -> String {
        return "I am ChildDependency and Injected"
    }
}

class GrandChildDependency: ChildDependency {
    override func explainMyself() -> String {
        return "I am GrandChildDependency and Injected"
    }
}

class GrandGrandChildDependency: GrandChildDependency {
    override func explainMyself() -> String {
        return "I am SomeOtherUpperDependency and Injected"
    }
}
