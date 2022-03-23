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
                Injector.sharedContext.release()
                Injector.switchInjector(to: Injector())
                Injector.shared.addScoped(for: Dependency.self, ChildDependency())
                Injector.shared.addScoped(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addScoped(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                Injector.sharedContext.release()
                let newInjected = WrappedInject()
                expect(newInjected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.dependency === newInjected.childDependency).to(beTrue())
                expect(injected.dependency === newInjected.dependency).to(beFalse())
                expect(injected.childDependency === newInjected.childDependency).to(beFalse())
            }
            it("should inject from init with nearest type") {
                let injected = InitInject()
                expect(injected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                Injector.sharedContext.release()
                let newInjected = WrappedInject()
                expect(newInjected.dependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.childDependency.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.grandChildDependency.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.dependency === newInjected.childDependency).to(beTrue())
                expect(injected.dependency === newInjected.dependency).to(beFalse())
                expect(injected.childDependency === newInjected.childDependency).to(beFalse())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                Injector.sharedContext.release()
                let newInjected = WrappedSafeInject()
                expect(newInjected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(newInjected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(newInjected.dependency === newInjected.childDependency).to(beTrue())
                expect(injected.dependency === newInjected.dependency).to(beFalse())
                expect(injected.childDependency === newInjected.childDependency).to(beFalse())
            }
            it("should inject from init with nearest type") {
                let injected = InitSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
                Injector.sharedContext.release()
                let newInjected = WrappedSafeInject()
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
                Injector.shared.resolvers.removeAll()
                Injector.shared.cleanCachedAndGroup()
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
