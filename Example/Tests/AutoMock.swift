//
//  AutoMock.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 22/2/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Impose

protocol MyAutoMockProtocol {
    var id: UUID { get }
}

class MyAutoMock: MyAutoMockProtocol, AutoInjectMock {
    static var registeredTypes: [Any.Type] = [MyAutoMockProtocol.self]
    let id: UUID = UUID()
}
