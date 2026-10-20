# WordCube 3D 🎲✨
*An iOS 3D Word-Search Game inspired by Point-Free's [isowords](https://github.com/pointfreeco/isowords)*

Built in Swift using **SwiftUI**, **SceneKit**, and a unidirectional **Store / Reducer** state architecture inspired by Point-Free's Composable Architecture (TCA).

---

## 🌟 Game Overview

**WordCube 3D** challenges players to find English words on a fully interactive 3x3x3 3D cube of letter blocks. As words are formed and submitted:
1. **Interactive 3D Navigation**: Single-finger orbit gesture to rotate the cube freely in 3D space with natural momentum and damping; two-finger pinch to zoom in/out.
2. **Adjacent Letter Selection**: Tap letter blocks across faces, edges, and corners (3D Moore neighborhood / Chebyshev distance = 1). Consecutive letters are visually linked in 3D space with glowing laser beams.
3. **Smooth Block Removal & Hidden Layers**: Submitting a valid 3+ letter word triggers a smooth scale-down, spin, and particle sparkle animation that clears the blocks—revealing the hidden inner blocks of the cube underneath!
4. **Scoring & Combo Multiplier**: Points are calculated from Scrabble-weighted letter frequencies, length multipliers (up to 3.0x), and consecutive word combo streaks (up to 5.0x with dynamic time decay).
5. **Native Dictionary Validation**: Instant offline English validation combining UIKit's `UITextChecker` with a bundled 150,000+ word corpus.
6. **Tactile & Auditory Immersion**: Distinct haptic feedback patterns (light tap, backtrack, success chime, error buzz, countdown warning) and audio effects.

---

## 📐 Architecture: Unidirectional Reducer / Store

The application is structured strictly around unidirectional data flow and clean separation of concerns:

```
[ User Interaction / Gestures / Timers ]
                   │
                   ▼ (GameAction)
        ┌─────────────────────┐
        │     GameReducer     │ ◄─── GameEnvironment (Dictionary, Haptics, Sound, Persistence)
        └─────────────────────┘
                   │
         mutates   ▼  returns
      ┌───────────────┐     ┌───────────────┐
      │   GameState   │     │ Effect<Action>│ (Async Tasks, Timers, Particle Triggers)
      └───────────────┘     └───────────────┘
              │                     │
              ▼                     ▼
     [ SwiftUI Views & SCNView ] ───┘ (Dispatches child actions back to Store)
```

- **[`Store<State, Action, Environment>`](WordCube3D/Architecture/Store.swift)**: `@MainActor` observable single source of truth managing state mutations and effect lifecycles.
- **[`Effect<Action>`](WordCube3D/Architecture/Effect.swift)**: Ergonomic representation of asynchronous effects (`run`, `merge`, `cancellable`, `cancel`).
- **[`GameState`](WordCube3D/State/GameState.swift)**: Pure value-type state holding the 3D grid, selected chain, score, multiplier, countdown, and active theme.
- **[`GameReducer`](WordCube3D/State/GameReducer.swift)**: Pure function `(inout GameState, GameAction, GameEnvironment) -> Effect<GameAction>`.
- **[`GameEnvironment`](WordCube3D/State/GameEnvironment.swift)**: Dependency container providing dictionary verification, tactile haptics, audio, and persistence.

---

## 📁 Project Structure

```
WordCube3D/
├── WordCube3D.xcodeproj/           # Fully configured Xcode Project with shared scheme
├── WordCube3D/
│   ├── App/
│   │   ├── WordCube3DApp.swift     # App entry point initializing root Store
│   │   └── Info.plist              # Application configuration
│   ├── Architecture/
│   │   ├── Store.swift             # Thread-safe TCA-inspired Store
│   │   └── Effect.swift            # Composable async side-effects
│   ├── Models/
│   │   ├── Coordinate3D.swift      # 3D grid indexing, distance & Moore adjacency
│   │   ├── CubeBlock.swift         # Letter block model & English weighted frequency
│   │   ├── FoundWord.swift         # Validated word model with point records
│   │   └── GameTheme.swift         # Ceramic, Obsidian, Cyberpunk, & Sunset themes
│   ├── State/
│   │   ├── GameState.swift         # Single source-of-truth state definition
│   │   ├── GameAction.swift        # Action enum for unidirectional flow
│   │   ├── GameReducer.swift       # Pure game rules and state transitions
│   │   └── GameEnvironment.swift   # Service dependencies
│   ├── Services/
│   │   ├── DictionaryService.swift # UITextChecker + bundled English word list
│   │   ├── HapticService.swift     # Tactile feedback generator
│   │   ├── SoundService.swift      # System sound audio effects
│   │   └── PersistenceService.swift# UserDefaults high-score & career tracking
│   ├── SceneKit/
│   │   ├── CubeSceneRenderer.swift # 3D scene, lighting, camera & orbit inertia
│   │   ├── CubeNode.swift          # SCNNode box with face textures & removal animation
│   │   ├── BlockTextureGenerator.swift # Dynamic CoreGraphics face texture renderer
│   │   ├── ChainConnectionRenderer.swift # 3D glowing connector beams
│   │   └── WordCubeSCNView.swift   # UIViewRepresentable wrapping SCNView
│   ├── Views/
│   │   ├── GameView.swift          # Main game screen coordinating 3D view & HUD
│   │   ├── HUD/
│   │   │   ├── TopHUDBar.swift     # Timer, score, best score & control buttons
│   │   │   ├── WordChainTray.swift # Active letter chain, submit & backtrack buttons
│   │   │   ├── ComboMultiplierBadge.swift # Decaying multiplier gauge
│   │   │   └── FloatingBannerView.swift  # Floating status banners
│   │   ├── Overlays/
│   │   │   ├── GameOverModal.swift # Final score, career best & replay options
│   │   │   ├── WordHistorySheet.swift # List of all words found in session
│   │   │   └── SettingsSheet.swift # Themes, haptics, sounds, shuffle & rules
│   │   └── Components/
│   │       ├── LetterTileView.swift # Individual tactile letter tile
│   │       ├── GlassCard.swift     # Frosted glassmorphism container
│   │       └── CircularTimerProgress.swift # Circular countdown gauge
│   └── Resources/
│       ├── Assets.xcassets/        # AppIcon & AccentColor catalog
│       └── words_common.txt        # 150,000+ word offline English vocabulary
└── WordCube3DTests/
    ├── WordCube3DTests.swift       # Coordinate adjacency, points & dictionary tests
    └── ReducerTests.swift          # State transitions, rules & combo tests
```

---

## 🎮 How to Play

1. **Orbit**: Drag anywhere on the 3D viewport with **one finger** to rotate the cube in any direction. Lift your finger to feel the smooth inertia.
2. **Zoom**: Pinch with **two fingers** to zoom closer or further away.
3. **Select Letters**: Tap any visible block to begin spelling a word. Tap an adjacent block (sharing a face, edge, or corner) to extend the word chain. A 3D laser beam visually connects your selected letters!
4. **Backtrack**: Tap the last selected letter to undo it, or tap an earlier letter in the chain to truncate back to that letter.
5. **Submit**: When you have 3 or more letters, hit the **SUBMIT WORD** button.
   - If valid: blocks smoothly scale down and burst into sparkles, revealing previously hidden inner blocks.
   - If invalid or duplicate: you receive an error banner and haptic feedback.
6. **Combos**: Score words in quick succession before the multiplier bar runs out to ramp up your score multiplier up to **5.0x**!

---

## 🛠️ Building & Running

### Requirements
- **macOS Sonoma / Sequoia / newer**
- **Xcode 15+ / 16+**
- **iOS 17.0+** (iPhone or iPad)

### Running in Xcode
1. Open `WordCube3D.xcodeproj` in Xcode:
   ```bash
   open WordCube3D/WordCube3D.xcodeproj
   ```
2. Select an iOS Simulator (e.g. **iPhone 16 Pro**) or a connected physical iPhone.
3. Press **Cmd + R** to Build & Run!
# Word-Cube-Swift-Game
