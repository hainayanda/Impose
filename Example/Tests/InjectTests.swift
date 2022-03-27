//
//  InjectTests.swift
//  Impose_Tests
//
//  Created by Nayanda Haberty on 23/03/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Impose

class InjectTests: QuickSpec {
    override func spec() {
        describe("singleton test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addSingleton(for: Dependency.self, ChildDependency())
                Injector.shared.addSingleton(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addSingleton(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
            }
            it("should inject from init with nearest type") {
                let injected = InitInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
            }
            it("should inject from init with nearest type") {
                let injected = InitSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
            }
        }
        describe("transient test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addTransient(for: Dependency.self, ChildDependency())
                Injector.shared.addTransient(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addTransient(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beFalse())
            }
            it("should inject from init with nearest type") {
                let injected = InitInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beFalse())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beFalse())
            }
            it("should inject from init with nearest type") {
                let injected = InitSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beFalse())
            }
        }
        describe("scoped test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addScoped(for: Dependency.self, ChildDependency())
                Injector.shared.addScoped(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addScoped(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedInject(using: Injector.shared.newScopedContext())
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                
                expect(injected.sub.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.sub.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.sub.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.sub.dependency === injected.sub.childDependency).to(beTrue())
                
                // sub and super should have same dependency
                expect(injected.sub.dependency === injected.dependency).to(beTrue())
                expect(injected.sub.childDependency === injected.childDependency).to(beTrue())
                expect(injected.sub.grandChildDependency === injected.grandChildDependency).to(beTrue())
                
                let newInjected = WrappedInject(using: Injector.shared.newScopedContext())
                expect(newInjected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.dependency === newInjected.childDependency).to(beTrue())
                
                expect(newInjected.sub.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.sub.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.sub.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.sub.dependency === newInjected.sub.childDependency).to(beTrue())
                
                // sub and super should have same dependency
                expect(newInjected.sub.dependency === newInjected.dependency).to(beTrue())
                expect(newInjected.sub.childDependency === newInjected.childDependency).to(beTrue())
                expect(newInjected.sub.grandChildDependency === newInjected.grandChildDependency).to(beTrue())
                
                expect(injected.dependency === newInjected.dependency).to(beFalse())
                expect(injected.childDependency === newInjected.childDependency).to(beFalse())
                expect(injected.grandChildDependency === newInjected.grandChildDependency).to(beFalse())
                expect(injected.sub.dependency === newInjected.sub.dependency).to(beFalse())
                expect(injected.sub.childDependency === newInjected.sub.childDependency).to(beFalse())
                expect(injected.sub.grandChildDependency === newInjected.sub.grandChildDependency).to(beFalse())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject(using: Injector.shared.newScopedContext())
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                let newInjected = WrappedSafeInject(using: Injector.shared.newScopedContext())
                expect(newInjected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.dependency === newInjected.childDependency).to(beTrue())
                expect(injected.dependency === newInjected.dependency).to(beFalse())
                expect(injected.childDependency === newInjected.childDependency).to(beFalse())
            }
        }
        describe("negative test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.mappedResolvers.removeAll()
                Injector.shared.cleanCachedAndRepopulate()
            }
            it("should error") {
                expect({ try Injector.shared.resolve(Dependency.self) }).to(throwError())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject()
                expect(injected.dependency).to(beNil())
                expect(injected.childDependency).to(beNil())
                expect(injected.grandChildDependency).to(beNil())
            }
            it("should inject from init with nearest type") {
                let injected = InitSafeInject()
                expect(injected.dependency).to(beNil())
                expect(injected.childDependency).to(beNil())
                expect(injected.grandChildDependency).to(beNil())
            }
        }
    }
}
