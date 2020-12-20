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
        }
        describe("negative test") {
            beforeEach {
                Imposer.shared.providers.removeAll()
            }
            it("should error") {
                expect({ try Imposer.shared.imposedInstance(of: Dependency.self) }).to(throwError())
            }
        }
    }
}

public class InitInject {
    
    var dependency: Dependency
    var someDependency: SomeDependency
    var someOtherDependency: SomeOtherDependency
    
    init(dependency: Dependency = inject(),
         someDependency: SomeDependency = inject(),
         someOtherDependency: SomeOtherDependency = inject()) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherDependency = someOtherDependency
    }
}

public class OtherInitInject {
    
    var dependency: Dependency
    var someDependency: SomeDependency
    var someOtherUpperDependency: SomeOtherUpperDependency
    
    init(dependency: Dependency = inject(ifNoMatchUse: .furthestType),
         someDependency: SomeDependency = inject(ifNoMatchUse: .furthestType),
         someOtherUpperDependency: SomeOtherUpperDependency = inject(ifNoMatchUse: .furthestType)) {
        self.dependency = dependency
        self.someDependency = someDependency
        self.someOtherUpperDependency = someOtherUpperDependency
    }
}
