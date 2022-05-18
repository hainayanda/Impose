<p align="center">
  <img width="175" height="192" src="Impose.png"/>
</p>

# Impose

Impose is a simple dependency injection library for Swift

[![codebeat badge](https://codebeat.co/badges/e200329c-321e-432b-8281-beb6d4dc4293)](https://codebeat.co/projects/github-com-hainayanda-impose-main)
![build](https://github.com/hainayanda/Impose/workflows/build/badge.svg)
![test](https://github.com/hainayanda/Impose/workflows/test/badge.svg)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Version](https://img.shields.io/cocoapods/v/Impose.svg?style=flat)](https://cocoapods.org/pods/Impose)
[![License](https://img.shields.io/cocoapods/l/Impose.svg?style=flat)](https://cocoapods.org/pods/Impose)
[![Platform](https://img.shields.io/cocoapods/p/Impose.svg?style=flat)](https://cocoapods.org/pods/Impose)

## Requirements

- Swift 5.0 or higher (or 5.3 when using Swift Package Manager)
- iOS 9.3 or higher (or 10 when using Swift Package Manager)

### Only Swift Package Manager

- macOS 10.10 or higher
- tvOS 10 or higher

## Installation

### Cocoapods

Impose is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Impose', '~> 3.1.2'
```

### Swift Package Manager from XCode

- Add it using XCode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/hainayanda/Impose.git** as Swift Package URL
- Set rules at **version**, with **Up to Next Major** option and put **3.1.2** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/Impose.git", .upToNextMajor(from: "3.1.2"))
]
```

Use it in your target as `Impose`

```swift
 .target(
    name: "MyModule",
    dependencies: ["Impose"]
)
```

## Author

Nayanda Haberty, hainayanda@outlook.com

## License

Impose is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Basic Usage

Impose is very easy to use and straightforward, all you need to do is provide some provider for dependency:

```swift
Injector.shared.addSingleton(for: Dependency.self, SomeDependency())
```

and then use it in some of your classes using property wrapper or using global function

```swift
class InjectedByPropertyWrapper {
    @Injected var dependency: Dependency
    
    ...
    ...
}

class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency = inject(Dependency.self)) {
        self.dependency = dependency
    }
}
```

the provider is autoClosure type, so you can do something like this:

```swift
Injector.shared.addSingleton(for: Dependency.self) {
    dependency: SomeDependency = .init()
    dependency.doSomeSetup()
    return dependency
}
```

the provider automatically just creates one instance only from calling closure and reused the instance, so the closure is only called once. If you want the provider to call closure for every injection, you can use `addTransient` method:

```swift
Injector.shared.addTransient(for: Dependency.self, SomeDependency())
```

Don't forget that it will throw an uncatchable Error if the provider is not registered yet. If you want to catch the error manually, just use `tryInject` instead:

```swift
class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = nil) {
        do {
            self.dependency = dependency ?? try tryInject(for: Dependency.self)
        } catch {
            self.dependency = DefaultDependency()
        }
    }
}
```

## Safe Injection

Sometimes you just don't want your app to be throwing errors just because it's failing in dependency injection. In those cases, just use `@SafelyInjected` attribute or `injectIfProvided` function. It will return nil if the injection fails:

```swift
class InjectedByPropertyWrapper {
    @SafelyInjected var dependency: Dependency?
    
    ...
    ...
}

class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = injectIfProvided(for: Dependency.self)) {
        self.dependency = dependency
    }
}
```

You can always give closure or auto closure to call if the injection fails:

```swift
class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = inject(Dependency.self, ifFailUse: SomeDependency())) {
        self.dependency = dependency
    }
}
```

## Singleton Provider

The simplest injection Provider is Singleton provider. The provider just creates one instance, stores it, and reused the instance, so the closure is only called once. The instance will not be released until the Injector is released. It will be useful for shared instance dependencies:

```swift
Injector.shared.addSingleton(for: Dependency.self, SomeDependency())
```

## Transient Provider

Different from Singleton, Transient will not store the dependency at all, it will just recreate the dependency every time it's needed. The closure will be stored strongly tho. It will be useful for services that store nothing:

```swift
Injector.shared.addTransient(for: Dependency.self, SomeDependency())
```

## Weak Provider

This provider is a combination of singleton and transient providers. It will store the instance in a weak variable before returning it. Once the stored instance became nil, it will recreate a new instance for the next injection. The closure will be stored strongly tho. It will be useful for dependency that you want to use and shared but released when not used anymore:

```swift
Injector.shared.addWeakSingleton(for: Dependency.self, SomeDependency())
```

## Scoped Provider

You can scope your dependency so it will create a new singleton instance within a scope:

```swift
Injector.shared.addScoped(for: Dependency.self, SomeDependency())
```

To scope an object, you need to implement the Scopable protocol, as a mark that this object could have a different scope than global dependencies. Without a scope, this will behave like a singleton dependency:

```swift
class MyObject: Scopable {
    @Injected var dependency: Dependency
    
    ...
    ...
}
```

Scopable is declared like this:

```swift
public protocol Scopable {
    var scopeContext: InjectContext { get }
    func scoped(by context: InjectContext)
    func scopedUsingSameContext(as scope: Scopable)
}
```

you can create your context like this:

```swift
let myContext = Injector.shared.newScopedContext()
```

then use it for any object you need so it will then inject scoped dependency using that context instead of the global one:

```swift
myObject.scoped(by: myContext)
myOtherObject.scoped(by: myContext)
myAnyOtherObject.scopedUsingSameContext(as: myObject)
```

All of those three objects will have the same instance of the same scoped dependency. Any other object with no scope or different scope will have a different instance.

You can use `ScopableInitiable` instead if you want to have the capabilities to have to init with scope:

```swift
class MyObject: ScopableInitiable {
    @Injected var dependency: Dependency
    
    required init(using context: InjectContext) {
        scoped(by: context)
    }
    ...
    ...
}
```

There is one property wrapped named Scoped that can be used to make sure that property will be scoped using the same context when `scoped(by:)` is called or when the property is assigned:

```swift
class MyObject: Scopable {
    @Injected var dependency: Dependency
    @Scoped var myScopable: ScopableObject = .init()
    ...
    ...
}
```

## Circular Dependency

`Injected` and `SafelyInjected` propertyWrapper will resolve dependency lazily, thus it will work even if you have a circular dependency. But it will rise stack overflow error if you use inject function instead on init since it will resolve the dependency right away. Even tho circular dependency is not recommended, it will be better if you use propertyWrapper instead for injection to avoid this problem.

## Multiple Types for one Provider

You can register multiple types for one provider if you need to:

```swift
Injector.shared.addSingleton(for: [Dependency.self, OtherDependency.self], SomeDependency())
```

or for transient:

```swift
Injector.shared.addTransient(for: [Dependency.self, OtherDependency.self], SomeDependency())
```

or even for scoped:

```swift
Injector.shared.addScoped(for: [Dependency.self, OtherDependency.self], SomeDependency())
```

## Multiple Injectors

You could have multiple `Injector` to provide different dependencies for the same type:

```swift
Injector.shared.addTransient(for: Dependency.self, Primary())

let secondaryInjector = Injector()
secondaryInjector.addTransient(for: Dependency.self, Secondary())
```

to use the other injector, switch it:

```swift
Injector.switchInjector(to: secondaryInjector)
```

to switch back is as easy as calling the void method:

```swift
Injector.switchToDefaultInjector()
```

## Module Provider

If you have a modular project and want the individual module to inject everything manually by itself. You can use `ModuleProvider` protocol, and use it as a provider in the main module:

```swift
// this is in MyModule
class MyModuleInjector: ModuleProvider {

    func provide(for injector: Injector) {
        injector.addSingleton(for: Dependency.self, SomeDependency())
    }
}
```

then let's say in your `AppDelegate`:

```swift
import Impose
import MyModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        provideDependencies()
        // do something
        return true
    }
    
    func provideDependencies() {
        Injector.shared.provide(using: MyModuleInjector())
    }
}
```

It will call `provide(using:)` with the given `Injector`. You can add as many `ModuleProvider` as you need, but if the Module provides the same Dependency for the same type of resolver, it will override the previous one with the new one.

## Contribute

You know how, just clone and do pull request
