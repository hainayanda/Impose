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
pod 'Impose', '~> 2.0'
```

### Swift Package Manager from XCode

- Add it using XCode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/hainayanda/Impose.git** as Swift Package URL
- Set rules at **version**, with **Up to Next Major** option and put **2.0.0** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/Impose.git", .upToNextMajor(from: "2.0.0"))
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

the provider automatically just create one instance only from calling closure and reused the instance, so the closure only called once. If you want the provider to call closure for every injection, you can use addTransient method:

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

Sometimes you just don't want your app to be throwing errors just because it's failing in dependency injection. In those cases, just use `@SafelyInjected` attribute or `injectIfProvided` function. It will return nil if injection fail:

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

You can always give a closure or autoclosure to call if the injection fail:

```swift
class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = inject(Dependency.self, ifFailUse: SomeDependency())) {
        self.dependency = dependency
    }
}
```

## Scoped Injector

You can scoped your injector so it will not intervene with shared injector:

```swift
// this will create a new cloned injector, with all the resolver in initial state
var myInjector = Injector.shared.asScopedInjector()
```

Then you can use the injector as a custom scoped injector:

```swift
class InjectedByPropertyWrapper {
    @Injected var dependency: Dependency?
    
    init(_ injector: Injector) {
        // will inject all Injected property wrapper using given injector instead of the shared ones
        inject(self, with: injector)
    }
    
    ...
    ...
}
```

## Impose Context

You can manually control the instance creation by context scoped:

```swift
// or use default Injector.sharedContext if you want
let myContext = ImposeContext()

Injector.shared.addScoped(for: Dependency.self, in: myContext, SomeDependency())
```

It will then will behave like singleton dependency until myContext is released by ARC or manually:

```swift
// it will release all the created instance from Injector that bind with this context
// if after this moment new instance is required, it will then create a new one
myContext.release()
```

You can always get a context later if you don't want to keep it manually:

```swift
let myContext = Injector.context(of: Dependency.self)
```

it will return the context if the resolver is added by using scoped, otherwise it will return nil

## Multiple Type for one Provider

You can register multiple type for one provider if you need to:

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

## Multiple Injector

You could have multiple `Injector` to provide different dependencies for the same type:

```swift
Injector.shared.addTransient(for: Dependency.self, Primary())

let secondaryInjector = Injector()
secondaryInjector.addTransient(for: Dependency.self, Secondary())
```

to use the other injector, switch it:

```swift
Injector.swithInjector(to: secondaryInjector)
```

to switch back is as easy as calling void method:

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
