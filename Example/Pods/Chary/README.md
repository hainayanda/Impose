# Chary

Chary is a DispatchQueue Utilities for safer sync and asynchronous programming. It helps to avoid a race condition when dealing with multithreaded application

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/acc82b746a3345b6a7e91b249c52b50f)](https://www.codacy.com/gh/hainayanda/Chary/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=hainayanda/Chary&amp;utm_campaign=Badge_Grade)
![build](https://github.com/hainayanda/Chary/workflows/build/badge.svg)
![test](https://github.com/hainayanda/Chary/workflows/test/badge.svg)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Version](https://img.shields.io/cocoapods/v/Chary.svg?style=flat)](https://cocoapods.org/pods/Chary)
[![License](https://img.shields.io/cocoapods/l/Chary.svg?style=flat)](https://cocoapods.org/pods/Chary)
[![Platform](https://img.shields.io/cocoapods/p/Chary.svg?style=flat)](https://cocoapods.org/pods/Chary)


## Requirements

- Swift 5.0 or higher (or 5.3 when using Swift Package Manager)
- iOS 10.0 or higher

### Only Swift Package Manager

- macOS 10.0 or higher
- tvOS 10.10 or higher

## Installation

### Cocoapods

Chary is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Chary'
```

### Swift Package Manager from XCode

- Add it using XCode menu **File > Swift Package > Add Package Dependency**
- Add **<https://github.com/hainayanda/Chary.git>** as Swift Package URL
- Set rules at **version**, with **Up to Next Major** option and put **1.0.6** as its version
- Click next and wait

### Swift Package Manager from Package.swift

Add as your target dependency in **Package.swift**

```swift
dependencies: [
  .package(url: "https://github.com/hainayanda/Chary.git", .upToNextMajor(from: "1.0.6"))
]
```

Use it in your target as `Chary`

```swift
 .target(
    name: "MyModule",
    dependencies: ["Chary"]
)
```

## Author

Nayanda Haberty, hainayanda@outlook.com

## License

Pharos is available under the MIT license. See the LICENSE file for more info.

***

## Basic Usage

Two utilities come with Chary, `Atomic` propertyWrapper and `DispatchQueue` extensions

## Atomic propertyWrapper

Atomic propertyWrapper is a propertyWrapper to wrap a property so it could be accessed and edited atomically:

```swift
class MyClass {
    @Atomic var atomicString: String = "atomicString"
    ...
    ...
}
```

then the atomicString will be Thread safe regardless of where it is accessed or edited.

```swift
DispatchQueue.main.async {
    myClass.atomicString = "from main thread"
}
DispatchQueue.global().async {
    myClass.atomicString = "from global thread"
}
```

## DispatchQueue Extensions

Chary has some DispatchQueue Extension that will help when dealing with multithreaded.

### Check current queue

You can check current DispatchQueue using `isCurrentQueue(is:)` which will check is the queue given is the current queue or not.

```swift
myQueue = DispatchQueue(label: "myQueue")
myQueue.sync {
    // this will print true
    print(DispatchQueue.isCurrentQueue(is: myQueue))
}
// this will print false
print(DispatchQueue.isCurrentQueue(is: myQueue))
```

What it did do is registering the DispatchQueue given for detection and compare the current detectable queues with the given one:

```swift
public static func isCurrentQueue(is queue: DispatchQueue) -> Bool {
    queue.registerDetection()
    return current == queue
}
```

Calling `DispatchQueue.current` will not guarantee to return the current `DispatchQueue`, since it can only return only `DispatchQueue` that already been registered for detection.
There are some default `DispatchQueue` that will auto registered when `current` is called:
- `DispatchQueue.main`
- `DispatchQueue.global()`
- `DispatchQueue.global(qos: .background)`
- `DispatchQueue.global(qos: .default)`
- `DispatchQueue.global(qos: .unspecified)`
- `DispatchQueue.global(qos: .userInitiated)`
- `DispatchQueue.global(qos: .userInteractive)`
- `DispatchQueue.global(qos: .utility)`

Other than that, it will need manual call for `registerDetection()` to allow the `DispatchQueue` to be accesible by calling `DispatchQueue.current`. Since `isCurrentQueue(is:)` will automatically register the given `DispatchQueue`, the queue passed will be accesible from `DispatchQueue.current` after.

### Safe Sync

Running `sync` from `DispatchQueue` sometimes can raise an exception if it is called in the same `DispatchQueue`. 
To avoid this, you can use `safeSync` instead which will check the current queue first and decide whether it needs to run the block right away or by using the default `sync`.
You don't need to register the `DispatchQueue` since it will automatically register the `DispatchQueue` before checking:

```swift
DispatchQueue.main.safeSync {
    print("this will safely executed")
}
```

### Async if needed

Sometimes you want to execute the operation right away if it's in the right `DispatchQueue` instead of running it asynchronously by using `async`.
Like when you update UI, it's better if you run it right away instead of putting it in the asynchronous queue if you are already in DispatchQueue.main.
You can use `asyncIfNeeded` to achieve that functionality right away. It will check the current `DispatchQueue` and decide whether it needs to run right away or by using the default `async`.
You don't need to register the `DispatchQueue` since it will automatically register the `DispatchQueue` before checking:

```swift
DispatchQueue.main.asyncIfNeeded {
    print("this will executed right away or asynchronously if in different queue")
}
```

***

## Contribute

You know-how. Just clone and do a pull request
