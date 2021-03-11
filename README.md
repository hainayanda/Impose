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

the provider automatically just create one instance only (singleton). If you want the provider to create new instance for every injection, you can just pass option:

```swift
Imposer.impose(for: Dependency.self, option: .closureBased, SomeDependency())
```

or if you want to set it to singleton explicitly:

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

If the Imposer did not found exact type registered but multiple compatible type, it will use the nearest one to the requested type.

```swift
protocol Dependency {
    ...
    ...
}

class MyDependency: Dependency {
    ...
    ...
}

class YourDependency: MyDependency {
    ...
    ...
}

class OurDependency: YourDependency {
    ...
    ...
}
```

and you register your dependency like this:

```swift
Imposer.impose(for: Dependency.self, MyDependency())
Imposer.impose(for: YourDependency.self, YourDependency())
Imposer.impose(for: OurDependency.self, OurDependency())
```
then the result will be:

```swift
class InjectedByPropertyWrapper {
    @Injected var thisWillBeMyDependency: Dependency
    @Injected var thisWillBeYourDependency: MyDependency
    @Injected var thisWillBeYourDependencyToo: YourDependency
    @Injected var thisWillBeOurDependency: OurDependency
    
    ...
    ...
}


class InjectedByInit {
    var thisWillBeMyDependency: Dependency
    var thisWillBeYourDependency: MyDependency
    var thisWillBeYourDependencyToo: YourDependency
    var thisWillBeOurDependency: OurDependency
    
    init(thisWillBeMyDependency: Dependency = inject(),
         thisWillBeYourDependency: MyDependency = inject(),
         thisWillBeYourDependencyToo: YourDependency = inject(),
         thisWillBeOurDependency: OurDependency = inject()) {
        self.thisWillBeMyDependency = thisWillBeMyDependency
        self.thisWillBeYourDependency = thisWillBeYourDependency
        self.thisWillBeYourDependencyToo = thisWillBeYourDependencyToo
        self.thisWillBeOurDependency = thisWillBeOurDependency
    }
}
```

If you prefer the furthest type registered, then you can pass rules into propertyWrapper or inject function like this:

```swift
class InjectedByPropertyWrapper {
    @Injected(ifNoMatchUse: .furthest) 
    var thisWillBeMyDependency: Dependency
    
    @Injected(ifNoMatchUse: .furthest) 
    var thisWillBeOurDependency: MyDependency
    
    @Injected(ifNoMatchUse: .furthest) 
    var thisWillBeYourDependency: YourDependency
    
    @Injected(ifNoMatchUse: .furthest) 
    var thisWillBeOurDependencyToo: OurDependency
    
    ...
    ...
}


class InjectedByInit {
    var thisWillBeMyDependency: Dependency
    var thisWillBeOurDependency: MyDependency
    var thisWillBeYourDependency: YourDependency
    var thisWillBeOurDependencyToo: OurDependency
    
    init(thisWillBeMyDependency: Dependency = inject(ifNoMatchUse: .furthest),
         thisWillBeOurDependency: MyDependency = inject(ifNoMatchUse: .furthest),
         thisWillBeYourDependency: YourDependency = inject(ifNoMatchUse: .furthest),
         thisWillBeOurDependencyToo: OurDependency = inject(ifNoMatchUse: .furthest)) {
        self.thisWillBeMyDependency = thisWillBeMyDependency
        self.thisWillBeOurDependency = thisWillBeOurDependency
        self.thisWillBeYourDependency = thisWillBeYourDependency
        self.thisWillBeOurDependencyToo = thisWillBeOurDependencyToo
    }
}
```

### Using Casting

Sometimes even if you are using no match rules there will be some time that the dependency did not found. You could always tell Imposer to try casting dependency if there are no match at all. Simply pass `furthestAndCastable` or `nearestAndCastable` as no match rules, then it will try to cast the dependency into the one you needed if there's no match.
