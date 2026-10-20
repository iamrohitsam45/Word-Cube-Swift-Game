import Foundation

/// All user interactions and system events flowing into the Store reducer.
public enum GameAction: Equatable, Sendable {
    case onAppear
    case blockTapped(Coordinate3D)
    case submitWord
    case backtrackLastBlock
    case clearChain
    case timerTicked
    case comboTimerTicked
    case startNewGame(duration: TimeInterval)
    case togglePause
    case dismissBanner
    case blockRemovalCompleted(Set<Coordinate3D>)
    case replenishCube
    case shuffleCube
    case setTheme(GameTheme)
    case toggleHaptics
    case toggleSound
    case setHistoryPresented(Bool)
    case setSettingsPresented(Bool)
}
