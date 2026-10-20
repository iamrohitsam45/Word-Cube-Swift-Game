import SwiftUI

/// Settings sheet for customization, audio/haptic toggles, and game rules.
public struct SettingsSheet: View {
    public let state: GameState
    public let onThemeChange: (GameTheme) -> Void
    public let onHapticsToggle: () -> Void
    public let onSoundToggle: () -> Void
    public let onReplenish: () -> Void
    public let onShuffle: () -> Void
    public let onDismiss: () -> Void
    
    public init(
        state: GameState,
        onThemeChange: @escaping (GameTheme) -> Void,
        onHapticsToggle: @escaping () -> Void,
        onSoundToggle: @escaping () -> Void,
        onReplenish: @escaping () -> Void,
        onShuffle: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.state = state
        self.onThemeChange = onThemeChange
        self.onHapticsToggle = onHapticsToggle
        self.onSoundToggle = onSoundToggle
        self.onReplenish = onReplenish
        self.onShuffle = onShuffle
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            Form {
                // Visual Theme
                Section(header: Text("Visual Theme")) {
                    Picker("Theme", selection: Binding(
                        get: { state.theme },
                        set: { onThemeChange($0) }
                    )) {
                        ForEach(GameTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Feedback Preferences
                Section(header: Text("Sensory Feedback")) {
                    Toggle(isOn: Binding(
                        get: { state.hapticsEnabled },
                        set: { _ in onHapticsToggle() }
                    )) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.primary)
                            Text("Haptic Feedback")
                        }
                    }
                    
                    Toggle(isOn: Binding(
                        get: { state.soundEnabled },
                        set: { _ in onSoundToggle() }
                    )) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.primary)
                            Text("Sound Effects")
                        }
                    }
                }
                
                // Cube Actions
                Section(header: Text("Cube Controls")) {
                    Button(action: {
                        onReplenish()
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "cube.fill")
                                .foregroundColor(.blue)
                            Text("Replenish All Blocks")
                        }
                    }
                    
                    Button(action: {
                        onShuffle()
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "shuffle")
                                .foregroundColor(.orange)
                            Text("Shuffle Cube Letters")
                        }
                    }
                }
                
                // Lifetime Records
                Section(header: Text("Career Statistics")) {
                    HStack {
                        Text("High Score")
                        Spacer()
                        Text("\(PersistenceService.shared.highScore)")
                            .fontWeight(.bold)
                            .foregroundColor(state.theme.accentColor)
                    }
                    
                    HStack {
                        Text("Best Word")
                        Spacer()
                        Text(PersistenceService.shared.bestWord.isEmpty ? "—" : "\(PersistenceService.shared.bestWord) (\(PersistenceService.shared.bestWordPoints) pts)")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Games Played")
                        Spacer()
                        Text("\(PersistenceService.shared.gamesPlayed)")
                    }
                    
                    HStack {
                        Text("Total Words Found")
                        Spacer()
                        Text("\(PersistenceService.shared.totalWordsFound)")
                    }
                }
                
                // Game Rules
                Section(header: Text("How To Play")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Orbit: Drag with 1 finger to rotate the 3D cube in any direction.")
                        Text("• Zoom: Pinch with 2 fingers to zoom in or out.")
                        Text("• Select: Tap letters to build words of 3+ letters. Each next letter must be adjacent in 3D (face, edge, or corner).")
                        Text("• Backtrack: Tap the last selected letter to undo, or tap an earlier letter to backtrack to that point.")
                        Text("• Destruction: Submitting a valid word removes those blocks and reveals hidden inner blocks!")
                        Text("• Combo: Score consecutive words quickly to multiply points up to 5x.")
                    }
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Game Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
