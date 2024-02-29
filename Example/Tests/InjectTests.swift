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

// swiftlint:disable type_body_length
class InjectTests: QuickSpec {
    // swiftlint:disable function_body_length
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
                Injector.shared
                    .addSingleton(for: Dependency.self, ChildDependency())
                    .addSingleton(for: GrandChildDependency.self, GrandChildDependency())
                    .addSingleton(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                    .addSingleton(for: MyCircularB.self, MyB())
                    .addSingleton(for: MyCircularA.self, MyA())
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
                Injector.shared
                    .addTransient(for: Dependency.self, ChildDependency())
                    .addTransient(for: GrandChildDependency.self, GrandChildDependency())
                    .addTransient(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                    .addTransient(for: MyCircularB.self, MyB())
                    .addTransient(for: MyCircularA.self, MyA())
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
        describe("environmental test") {
            var dependency: Dependency!
            var childDependency: ChildDependency!
            var grandChildDependency: GrandChildDependency!
            beforeEach {
                dependency = ChildDependency()
                childDependency = GrandChildDependency()
                grandChildDependency = GrandGrandChildDependency()
            }
            it("should inject using same environment") {
                let sourceEnv = InjectEnv1()
                InjectionEnvironment.forObject(sourceEnv)
                    .inject(for: Dependency.self, dependency)
                
                expect(sourceEnv.dependency === dependency).to(beTrue())
                
                let derived1 = InjectEnv2()
                InjectionEnvironment.fromObject(sourceEnv, for: derived1)
                    .inject(for: ChildDependency.self, childDependency)
                
                expect(derived1.dependency === dependency).to(beTrue())
                expect(derived1.childDependency === childDependency).to(beTrue())
                
                let derived2 = InjectEnv3()
                InjectionEnvironment.fromObject(derived1, for: derived2)
                    .inject(for: GrandChildDependency.self, grandChildDependency)
                
                expect(derived2.dependency === dependency).to(beTrue())
                expect(derived2.childDependency === childDependency).to(beTrue())
                expect(derived2.grandChildDependency === grandChildDependency).to(beTrue())
            }
            it("should inject using same environment manually") {
                let sourceEnv = InjectEnv1()
                sourceEnv.dependency = dependency
                
                let derived1 = InjectEnv2()
                InjectionEnvironment.fromObject(sourceEnv, for: derived1)
                    .inject(for: ChildDependency.self, childDependency)
                
                expect(derived1.dependency === dependency).to(beTrue())
                
                let derived2 = InjectEnv3()
                InjectionEnvironment.fromObject(derived1, for: derived2)
                    .inject(for: GrandChildDependency.self, grandChildDependency)
                
                expect(derived2.dependency === dependency).to(beTrue())
            }
        }
        describe("weak test") {
            beforeEach {
                Injector.switchInjector(to: Injector())
                Injector.shared
                    .addWeakSingleton(for: Dependency.self, ChildDependency())
                    .addWeakSingleton(for: GrandChildDependency.self, GrandChildDependency())
                    .addWeakSingleton(for: GrandGrandChildDependency.self, GrandGrandChildDependency())
                    .addWeakSingleton(for: MyCircularB.self, MyB())
                    .addWeakSingleton(for: MyCircularA.self, MyA())
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
    // swiftlint:enable function_body_length
}
// swiftlint:enable type_body_length
