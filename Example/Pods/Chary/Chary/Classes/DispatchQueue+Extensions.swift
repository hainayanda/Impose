//
//  DispatchQueue+Extensions.swift
//  Chary
//
//  Copied and edited from https://stackoverflow.com/questions/17475002/get-current-dispatch-queue
//

import Foundation

// MARK: Detection

struct QueueReference {
    weak var queue: DispatchQueue?
}

fileprivate let detectionKey = DispatchSpecificKey<QueueReference>()

extension DispatchQueue {
    
    /// Try to get current queue. It will only show the one registered or accessible from OperationQueue.current, or SystemThread
    public static var current: DispatchQueue? {
        registerSystemDetection()
        if let registeredQueue = getSpecific(key: detectionKey)?.queue {
            return registeredQueue
        } else if let fromOpQ = OperationQueue.current?.underlyingQueue {
            fromOpQ.registerDetection()
            return fromOpQ
        } else if Thread.isMainThread {
            let main = DispatchQueue.main
            main.registerDetection()
            return main
        }
        return nil
    }
    
    /// Register all systems DispatchQueue for detection including: main, global, global background, global default, global user initiated, global user interactivity, global utiliity
    public static func registerSystemDetection() {
        [
            DispatchQueue.main, DispatchQueue.global(),
            DispatchQueue.global(qos: .background), DispatchQueue.global(qos: .default),
            DispatchQueue.global(qos: .unspecified), DispatchQueue.global(qos: .userInitiated),
            DispatchQueue.global(qos: .userInteractive), DispatchQueue.global(qos: .utility)
            
        ].forEach {
            $0.registerDetection()
        }
    }
    
    /// Register the current DispatchQueue for detection
    public func registerDetection() {
        self.setSpecific(key: detectionKey, value: QueueReference(queue: self))
    }
    
    /// Check is current queue is same as given queue.
    /// It will automatically register detection for the queue, so it will be better than using == operator manually
    /// - Parameter queue: Queue to check
    /// - Returns: True if the current queue is the same as the given queue
    public static func isCurrentQueue(is queue: DispatchQueue) -> Bool {
        queue.registerDetection()
        return current == queue
    }
}

// MARK: SafeSync

extension DispatchQueue {
    
    /// Perform safe synchronous task. It will run the block right away if turns out its on the same queue as the target
    /// - Parameter block: The work item to be invoked on the queue.
    /// - returns the value returned by the work item.
    public func safeSync<Return>(
        flags: DispatchWorkItemFlags = [],
        execute block: () throws -> Return) rethrows -> Return {
        return try ifAtDifferentQueue {
            let callerThread = Thread.current
            let partialResult: Return? = try sync(flags: flags) {
                let syncThread = Thread.current
                // make sure only call block if its on different thread
                // unless it will create a deadlock if the block are calling sync on same queue
                guard syncThread != callerThread else { return nil }
                return try block()
            }
            return try partialResult ?? block()
        } ifNot: {
            try block()
        }
    }
    
    /// Perform safe synchronous task. It will run the block right away if turns out its on the same queue as the target
    /// - Parameter workItem: The work item to be invoked on the queue.
    public func safeSync(execute workItem: DispatchWorkItem) {
        safeSync {
            workItem.perform()
        }
    }
    
    /// Perform asynchronous task if in different queue than the target. It will run the block right away if turns out its on the same queue as the target
    /// - Parameter block: The work item to be invoked on the queue.
    public func asyncIfNeeded(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute block: @escaping () -> Void) {
        ifAtDifferentQueue {
            async(qos: qos, flags: flags, execute: block)
        } ifNot: {
            block()
        }
    }
    
    /// Perform asynchronous task if in different queue than the target. It will run the block right away if turns out its on the same queue as the target
    /// - Parameter workItem: The work item to be invoked on the queue.
    public func asyncIfNeeded(execute workItem: DispatchWorkItem) {
        ifAtDifferentQueue {
            async(execute: workItem)
        } ifNot: {
            workItem.perform()
        }
    }
    
    /// Perform queue check to determined if its in same queue or not. The it will run one of the block regarding of the current queue
    /// - Parameters:
    ///   - block: Block that will be run if current queue different than the target
    ///   - doElse: Block that will be run if current queue same than the target
    /// - Returns: The value returned by the block
    public func ifAtDifferentQueue<Return>(
        do block: () throws -> Return,
        ifNot doElse: () throws -> Return) rethrows -> Return {
        try ifAtSameQueue(do: doElse, ifNot: block)
    }
    
    /// Perform queue check to determined if its in same queue or not. The it will run one of the block regarding of the current queue
    /// - Parameters:
    ///   - block: Block that will be run if current queue same than the target
    ///   - doElse: Block that will be run if current queue different than the target
    /// - Returns: The value returned by the block
    public func ifAtSameQueue<Return>(
        do block: () throws -> Return,
        ifNot doElse: () throws -> Return) rethrows -> Return {
        guard DispatchQueue.isCurrentQueue(is: self) else {
            return try doElse()
        }
        return try block()
    }
}
