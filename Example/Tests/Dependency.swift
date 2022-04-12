//
//  Dependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 20/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

protocol Dependency: AnyObject {
    
    var creationCount: Int { get }
    func explainMyself() -> String
}


class ChildDependency: Dependency {
    
    static var objectCreationCounter: Int = 0
    
    let creationCount: Int
    
    init() {
        ChildDependency.objectCreationCounter += 1
        creationCount = ChildDependency.objectCreationCounter
    }
    
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
