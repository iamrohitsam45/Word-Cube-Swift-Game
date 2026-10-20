import Foundation
import Combine

/// Represents an asynchronous or synchronous side-effect returned by a Reducer,
/// directly modeled after Point-Free's Composable Architecture principles.
public struct Effect<Action> {
    public typealias Send = @Sendable (Action) -> Void
    
    public enum Operation {
        case none
        case run((@escaping Send) async -> Void)
        case merge([Effect<Action>])
        case cancel(AnyHashable)
    }
    
    public let operation: Operation
    public let cancelId: AnyHashable?
    
    public init(operation: Operation, cancelId: AnyHashable? = nil) {
        self.operation = operation
        self.cancelId = cancelId
    }
    
    /// No effect is performed.
    public static var none: Effect<Action> {
        Effect(operation: .none)
    }
    
    /// Executes an async block that can send zero or more actions back to the Store.
    public static func run(
        priority: TaskPriority? = nil,
        _ work: @escaping (@escaping Send) async -> Void
    ) -> Effect<Action> {
        Effect(operation: .run(work))
    }
    
    /// Immediately sends a single action back to the Store.
    public static func send(_ action: Action) -> Effect<Action> {
        .run { send in
            send(action)
        }
    }
    
    /// Executes a fire-and-forget async side-effect that produces no actions.
    public static func fireAndForget(
        _ work: @escaping () async -> Void
    ) -> Effect<Action> {
        .run { _ in
            await work()
        }
    }
    
    /// Merges multiple effects into a single composite effect.
    public static func merge(_ effects: Effect<Action>...) -> Effect<Action> {
        Effect(operation: .merge(effects))
    }
    
    /// Merges an array of effects.
    public static func merge(_ effects: [Effect<Action>]) -> Effect<Action> {
        Effect(operation: .merge(effects))
    }
    
    /// Cancels any ongoing task previously scheduled with the matching identifier.
    public static func cancel(id: AnyHashable) -> Effect<Action> {
        Effect(operation: .cancel(id))
    }
    
    /// Attaches a cancellation identifier to an effect so it can be canceled later.
    public func cancellable(id: AnyHashable) -> Effect<Action> {
        Effect(operation: self.operation, cancelId: id)
    }
}
