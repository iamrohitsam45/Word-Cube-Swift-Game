import Foundation
import SwiftUI
import Combine

/// A thread-safe, unidirectional Store inspired by Point-Free's Composable Architecture (TCA).
/// Holds single source-of-truth state, executes pure reducer logic, and coordinates side effects.
@MainActor
public final class Store<State, Action, Environment>: ObservableObject {
    @Published public private(set) var state: State
    
    private let reducer: (inout State, Action, Environment) -> Effect<Action>
    private let environment: Environment
    private var runningTasks: [AnyHashable: Task<Void, Never>] = [:]
    
    public init(
        initialState: State,
        reducer: @escaping (inout State, Action, Environment) -> Effect<Action>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    /// Sends an action into the store to mutate state and trigger side effects.
    public func send(_ action: Action) {
        let effect = reducer(&state, action, environment)
        handleEffect(effect)
    }
    
    /// Helper to create a two-way SwiftUI Binding to a slice of state.
    public func binding<Value>(
        get: @escaping (State) -> Value,
        send: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { get(self.state) },
            set: { [weak self] newValue in
                self?.send(send(newValue))
            }
        )
    }
    
    private func handleEffect(_ effect: Effect<Action>) {
        switch effect.operation {
        case .none:
            break
            
        case .run(let work):
            let task = Task { [weak self] in
                await work { [weak self] childAction in
                    Task { @MainActor [weak self] in
                        self?.send(childAction)
                    }
                }
            }
            if let cancelId = effect.cancelId {
                runningTasks[cancelId]?.cancel()
                runningTasks[cancelId] = task
            }
            
        case .merge(let effects):
            for subEffect in effects {
                handleEffect(subEffect)
            }
            
        case .cancel(let cancelId):
            runningTasks[cancelId]?.cancel()
            runningTasks.removeValue(forKey: cancelId)
        }
    }
    
    deinit {
        for (_, task) in runningTasks {
            task.cancel()
        }
    }
}
