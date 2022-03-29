//
//  CircularDependency.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 29/03/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Impose

protocol MyCircularA: Scopable, AnyObject {
    var myCircularB: MyCircularB { get set }
}

protocol MyCircularB: Scopable, AnyObject {
    var myCircularA: MyCircularA { get set }
}

class MyA: MyCircularA {
    @Injected var myCircularB: MyCircularB
}

class MyB: MyCircularB {
    @Injected var myCircularA: MyCircularA
}
