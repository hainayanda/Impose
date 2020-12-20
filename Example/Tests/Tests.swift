// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import Impose

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("positive test") {
            beforeEach {
                Imposer.impose(for: Dependency.self, SomeDependency())
                Imposer.impose(for: SomeOtherDependency.self, SomeOtherDependency())
                Imposer.impose(for: SomeOtherUpperDependency.self, SomeOtherUpperDependency())
            }
            afterEach {
                Imposer.shared.providers.removeAll()
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedInject()
                expect(injected.dependency.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
                expect(injected.someOtherDependency.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
            }
            it("should inject from init with nearest type") {
                let injected = InitInject()
                expect(injected.dependency.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
                expect(injected.someOtherDependency.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
            }
            it("should inject from property wrapper with furthest type") {
                let injected = OtherWrappedInject()
                expect(injected.dependency.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
                expect(injected.someOtherUpperDependency.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
            }
            it("should inject from init with furthest type") {
                let injected = OtherInitInject()
                expect(injected.dependency.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
                expect(injected.someOtherUpperDependency.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedUnforceInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency?.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
                expect(injected.someOtherDependency?.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
            }
            it("should inject from init with nearest type") {
                let injected = InitUnforceInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency?.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
                expect(injected.someOtherDependency?.explainMyself()).to(equal("I am SomeOtherDependency and Injected"))
            }
            it("should inject from property wrapper with furthest type") {
                let injected = OtherWrappedUnforceInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency?.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
                expect(injected.someOtherUpperDependency?.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
            }
            it("should inject from init with furthest type") {
                let injected = OtherInitUnforceInject()
                expect(injected.dependency?.explainMyself()).to(equal("I am SomeDependency and Injected"))
                expect(injected.someDependency?.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
                expect(injected.someOtherUpperDependency?.explainMyself()).to(equal("I am SomeOtherUpperDependency and Injected"))
            }
        }
        describe("negative test") {
            beforeEach {
                Imposer.shared.providers.removeAll()
            }
            it("should error") {
                expect({ try Imposer.shared.imposedInstance(of: Dependency.self) }).to(throwError())
            }
            it("should inject from property wrapper with nearest type") {
                let injected = WrappedUnforceInject()
                expect(injected.dependency).to(beNil())
                expect(injected.someDependency).to(beNil())
                expect(injected.someOtherDependency).to(beNil())
            }
            it("should inject from init with nearest type") {
                let injected = InitUnforceInject()
                expect(injected.dependency).to(beNil())
                expect(injected.someDependency).to(beNil())
                expect(injected.someOtherDependency).to(beNil())
            }
            it("should inject from property wrapper with furthest type") {
                let injected = OtherWrappedUnforceInject()
                expect(injected.dependency).to(beNil())
                expect(injected.someDependency).to(beNil())
                expect(injected.someOtherUpperDependency).to(beNil())
            }
            it("should inject from init with furthest type") {
                let injected = OtherInitUnforceInject()
                expect(injected.dependency).to(beNil())
                expect(injected.someDependency).to(beNil())
                expect(injected.someOtherUpperDependency).to(beNil())
            }
        }
    }
}
