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
        describe("AutoInjectMock test") {
            it("should do auto injection") {
                let mock: MyAutoMockProtocol = MyAutoMock().injected()
                let injectedMock = inject(MyAutoMockProtocol.self)
                expect(mock.id).to(equal(injectedMock.id))
            }
        }
        describe("singleton test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addSingleton(for: Dependency.self, ChildDependency())
                Injector.shared.addSingleton(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addSingleton(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                Injector.shared.addSingleton(for: MyCircularB.self, MyB())
                Injector.shared.addSingleton(for: MyCircularA.self, MyA())
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
            it("should stored dependency strongly") {
                let injected = WrappedInject()
                let dependencyIdentifier = injected.dependency.creationCount
                let childDependencyIdentifier = injected.childDependency.creationCount
                let grandChildDependencyIdentifier = injected.grandChildDependency.creationCount
                let newInjected = WrappedInject()
                let newDependencyIdentifier = newInjected.dependency.creationCount
                let newChildDependencyIdentifier = newInjected.childDependency.creationCount
                let newGrandChildDependencyIdentifier = newInjected.grandChildDependency.creationCount
                expect(dependencyIdentifier).to(equal(newDependencyIdentifier))
                expect(childDependencyIdentifier).to(equal(newChildDependencyIdentifier))
                expect(grandChildDependencyIdentifier).to(equal(newGrandChildDependencyIdentifier))
            }
            it("should not error with circular dependency") {
                let myA: MyCircularA = inject()
                let myB: MyCircularB = inject()
                expect(myA === myB.myCircularA).to(beTrue())
                expect(myB === myA.myCircularB).to(beTrue())
            }
        }
        describe("transient test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addTransient(for: Dependency.self, ChildDependency())
                Injector.shared.addTransient(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addTransient(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                Injector.shared.addTransient(for: MyCircularB.self, MyB())
                Injector.shared.addTransient(for: MyCircularA.self, MyA())
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
            it("should not stored dependency") {
                let injected = WrappedInject()
                let dependencyIdentifier = injected.dependency.creationCount
                let childDependencyIdentifier = injected.childDependency.creationCount
                let grandChildDependencyIdentifier = injected.grandChildDependency.creationCount
                let newInjected = WrappedInject()
                let newDependencyIdentifier = newInjected.dependency.creationCount
                let newChildDependencyIdentifier = newInjected.childDependency.creationCount
                let newGrandChildDependencyIdentifier = newInjected.grandChildDependency.creationCount
                expect(dependencyIdentifier).toNot(equal(newDependencyIdentifier))
                expect(childDependencyIdentifier).toNot(equal(newChildDependencyIdentifier))
                expect(grandChildDependencyIdentifier).toNot(equal(newGrandChildDependencyIdentifier))
            }
            it("should not error with circular dependency") {
                let myA: MyCircularA = inject()
                let myB: MyCircularB = inject()
                expect(myA === myB.myCircularA).to(beFalse())
                expect(myB === myA.myCircularB).to(beFalse())
            }
        }
        describe("scoped test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addScoped(for: Dependency.self, ChildDependency())
                Injector.shared.addScoped(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addScoped(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                Injector.shared.addScoped(for: MyCircularB.self, MyB())
                Injector.shared.addScoped(for: MyCircularA.self, MyA())
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
            it("should not error with circular dependency") {
                let context = Injector.shared.newScopedContext()
                let myA: MyCircularA = inject(providedBy: context)
                let myB: MyCircularB = inject(providedBy: context)
                expect(myA === myB.myCircularA).to(beTrue())
                expect(myB === myA.myCircularB).to(beTrue())
            }
        }
        describe("weak test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared.addWeakSingleton(for: Dependency.self, ChildDependency())
                Injector.shared.addWeakSingleton(for: GrandChildDependency.self, GrandChildDependency())
                Injector.shared.addWeakSingleton(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                Injector.shared.addWeakSingleton(for: MyCircularB.self, MyB())
                Injector.shared.addWeakSingleton(for: MyCircularA.self, MyA())
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
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedSafeInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.childDependency?.explainMyself()).to(equal("I am ChildDependency and Injected"))
                expect(injected.grandChildDependency?.explainMyself()).to(equal("I am GrandChildDependency and Injected"))
                expect(injected.dependency === injected.childDependency).to(beTrue())
            }
            it("should stored dependency weakly") {
                var injected: WrappedInject? = WrappedInject()
                let dependencyIdentifier = injected!.dependency.creationCount
                let childDependencyIdentifier = injected!.childDependency.creationCount
                let grandChildDependencyIdentifier = injected!.grandChildDependency.creationCount
                // recreate dependency
                injected = WrappedInject()
                let newDependencyIdentifier = injected!.dependency.creationCount
                let newChildDependencyIdentifier = injected!.childDependency.creationCount
                let newGrandChildDependencyIdentifier = injected!.grandChildDependency.creationCount
                expect(dependencyIdentifier).toNot(equal(newDependencyIdentifier))
                expect(childDependencyIdentifier).toNot(equal(newChildDependencyIdentifier))
                expect(grandChildDependencyIdentifier).toNot(equal(newGrandChildDependencyIdentifier))
            }
            it("should not create new dependency") {
                let injected = WrappedInject()
                let dependencyIdentifier = injected.dependency.creationCount
                let childDependencyIdentifier = injected.childDependency.creationCount
                let grandChildDependencyIdentifier = injected.grandChildDependency.creationCount
                let newInjected = WrappedInject()
                let newDependencyIdentifier = newInjected.dependency.creationCount
                let newChildDependencyIdentifier = newInjected.childDependency.creationCount
                let newGrandChildDependencyIdentifier = newInjected.grandChildDependency.creationCount
                expect(dependencyIdentifier).to(equal(newDependencyIdentifier))
                expect(childDependencyIdentifier).to(equal(newChildDependencyIdentifier))
                expect(grandChildDependencyIdentifier).to(equal(newGrandChildDependencyIdentifier))
            }
            it("should not error with circular dependency") {
                let myA: MyCircularA = inject()
                let myB: MyCircularB = inject()
                expect(myA === myB.myCircularA).to(beTrue())
                expect(myB === myA.myCircularB).to(beTrue())
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
