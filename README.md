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
pod 'Impose', '~> 1.2'
```

### Swift Package Manager from XCode

- Add it using XCode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/hainayanda/Impose.git** as Swift Package URL
- Set rules at **version**, with **Up to Next Major** option and put **1.2.6** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/Impose.git", .upToNextMajor(from: "1.2.6"))
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
Imposer.impose(for: Dependency.self, SomeDependency())
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
    
    init(dependency: Dependency = inject()) {
        self.dependency = dependency
    }
}
```

the provider is autoClosure type, so you can do something like this:

```swift
Imposer.impose(for: Dependency.self) {
    dependency: SomeDependency = .init()
    dependency.doSomeSetup()
    return dependency
}
```

the provider automatically just create one instance only from calling closure and reused the instance, so the closure only called once. If you want the provider to call closure for every injection, you can just pass the option:

```swift
Imposer.impose(for: Dependency.self, option: .closureBased, SomeDependency())
```

or if you want to set it to a single instance explicitly:

```swift
Imposer.impose(for: Dependency.self, option: .singleInstance, SomeDependency())
```

Don't forget that it will throw an uncatchable Error if the provider is not registered yet. If you want to catch the error manually, just use `tryInject` instead:

```swift
class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = nil) {
        do {
            self.dependency = dependency ?? try tryInject()
        } catch {
            self.dependency = DefaultDependency()
        }
    }
}
```

## Optional Inject

Sometimes you just don't want your app to be throwing errors just because it's failing in dependency injection. In those cases, just use `@UnforceInjected` attribute or `unforceInject` function. It will return nil if injection fail:

```swift
class InjectedByPropertyWrapper {
    @UnforceInjected var dependency: Dependency?
    
    ...
    ...
}

class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency? = unforceInject()) {
        self.dependency = dependency
    }
}
```

## No Match Rules

If the Imposer did not found the exact type registered but multiple compatible types, it will use the nearest one to the requested type. Like in this example:

```swift
protocol Dependency {
    ...
    ...
}

class NearestToDependency: Dependency {
    ...
    ...
}

class MidwayToDependency: NearestToDependency {
    ...
    ...
}

class FurthestToDependency: MidwayToDependency {
    ...
    ...
}
```

so if you provide dependency like this:

```swift
Imposer.impose(for: NearestToDependency.self, NearestToDependency())
Imposer.impose(for: MidwayToDependency.self, MidwayToDependency())
Imposer.impose(for: FurthestToDependency.self, FurthestToDependency())
```

and you try to inject `Dependency` protocol which Imposer already have three candidates for that, by default Imposer will return `NearestToDependency` since its the nearest one to `Dependency`:

```swift
class MyClass {
    // this will be NearestToDependency
    @Injected var dependency: Dependency
}
```

but if you want to get another dependency, you could pass `InjectionRules`:
- **nearest** which will return the nearest one found
- **furthest** which will return the furthest one found
- **nearestAndCastable** same like nearest, but will be using type casting too when searching dependency
- **furthestAndCastable** same as furthest, but will be using type casting too when searching dependency


```swift
class MyClass {
    // this will be NearestToDependency
    @Injected var dependency: Dependency
    
    // this will be FurthestToDependency
    @Injected(ifNoMatchUse: .furthest) var furthestDependency: Dependency
}
```

it can apply to the inject function too:

```swift
// this will be NearestToDependency
var dependency: Dependency = inject()

// this will be FurthestToDependency
var furthestDependency: Dependency = inject(ifNoMatchUse: .furthest)
```

Keep in mind, using `nearestAndCastable` and `furthestAndCastable` will create/using the dependency instance and cast it to Dependency needed, so if the instance injected using one or more Dependencies that circular with itself, it will be raising a stack overflow, so it's better to avoid it unless you really need it and make sure the dependency is safe.

## Multiple Imposer

You could have multiple `Imposer` to provide different dependencies for the same type by using `ImposerType`.  `ImposerType` is an enumeration to mark the `Imposer`:

- **primary** which is the default Imposer
- **secondary** which is the secondary Imposer where the Imposer will search if dependency is not present in the primary
- **custom(AnyHashable)**  which is the optional Imposer where the Imposer will search if dependency is not present in the primary or secondary

To use `ImposerType` other than primary, use static method `imposer(for:)`. It will search the `Imposer` for given type and create new if the `Imposer` did not found:

```swift
let secondaryImposer = Imposer.imposer(for: .secondary)
secondaryImposer.impose(for: Dependency.self, SomeDependency())
```

Then pass the type to propertyWrapper or global function as the first parameter:

```swift
class InjectedByPropertyWrapper {
    @Injected(from: .secondary) var dependency: Dependency
    
    ...
    ...
}

class InjectedByInit {
    var dependency: Dependency
    
    init(dependency: Dependency = inject(from: .secondary)) {
        self.dependency = dependency
    }
}
```

It will search the dependency from the `Imposer` for the given type and if the dependency is not found, it will try to search from the other available `Imposer` started from primary

## Module Injector

If you have a modular project and want the individual module to inject everything manually by itself. You can use `ModuleInjector` protocol, and use it as a provider in the main module:

```swift
// this is in MyModule
class MyModuleInjector: ModuleInjector {
    var type: ImposerType { .primary }
    
    func provide(for imposer: Imposer) {
        imposer.impose(for: Dependency.self, SomeDependency())
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
        Imposer.provide(using: MyModuleInjector())
    }
}
```

It will call `provide(using:)` with primary `Imposer`. type of imposer is optional, the default value is `primary`. You can add as many `ModuleInjector` as you need, but if the Module provides the same Dependency for the same type of `Imposer`, it will override the previous one with the new one.

## Contribute

You know how, just clone and do pull request
