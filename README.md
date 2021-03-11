<p align="center">
  <img width="175" height="192" src="Impose.png"/>
</p>

# Impose

Impose is a simple dependency injection library for Swift

![build](https://github.com/nayanda1/Impose/workflows/build/badge.svg)
![test](https://github.com/nayanda1/Impose/workflows/test/badge.svg)
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
pod 'Impose'
```

### Swift Package Manager from XCode

- Add it using xcode menu **File > Swift Package > Add Package Dependency**
- Add **https://github.com/nayanda1/Impose.git** as Swift Package url
- Set rules at **version**, with **Up to Next Major** option and put **1.2.0** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
    .package(url: "https://github.com/nayanda1/Impose.git", .upToNextMajor(from: "1.2.0"))
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

Nayanda Haberty, nayanda1@outlook.com

## License

Impose is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Basic Usage

Impose is very easy to use and straightforward, all you need to do is provide some provider for dependency:

```swift
Imposer.impose(for: Dependency.self, SomeDependency())
```

and then use it in some of your class using property wrapper or using global function

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

the provider automatically just create one instance only from calling closure and reused the instance, so the closure only called once. If you want the provider to call closure for every injection, you can just pass option:

```swift
Imposer.impose(for: Dependency.self, option: .closureBased, SomeDependency())
```

or if you want to set it to single instance explicitly:

```swift
Imposer.impose(for: Dependency.self, option: .singleInstance, SomeDependency())
```

Don't forget that it will throw uncatchable Error if the provider is not registered yet. If you want to catch the error manually, just use `tryInject` instead:

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

Sometimes you just don't want your app to be throwing error because of failure in dependency injection. At those cases, just use `@UnforceInjected` attribute or `unforceInject` function. It will return nil if injection fail:

```swift
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

If the Imposer did not found exact type registered but multiple compatible type, it will use the nearest one to the requested type. Like in this example:

```swift
protocol Dependency {
    ...
    ...
}

class NearestToDependency: Dependency {
    ...
    ...
}

class MidwayToDependency: MyDependency {
    ...
    ...
}

class FurthestToDependency: YourDependency {
    ...
    ...
}
```

so if you provide dependency like this:

```swift
Imposed.impose(for: NearestToDependency.self, NearestToDependency())
Imposed.impose(for: MidwayToDependency.self, MidwayToDependency())
Imposed.impose(for: FurthestToDependency.self, FurthestToDependency())
```

and you try to get injected `Dependency` protocol which Imposer already have three candidate for that, by default Imposer will return `NearestToDependency` since its the nearest one to `Dependency`:

```swift
class MyClass {
    // this will be NearestToDependency
    @Injected var dependency: Dependency
}
```

but if you want to get other dependency, you could pass `InjectionRules`:
- **nearest** which will return the nearest one found
- **furthest** which will return the furthest one found
- **nearestAndCastable** same like nearest, but will using type casting too when searching dependency
- **furthestAndCastable** same like furthest, but will using type casting too when searching dependency


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
