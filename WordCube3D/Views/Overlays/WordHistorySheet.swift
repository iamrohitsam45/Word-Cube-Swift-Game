import SwiftUI

/// Sheet displaying the list of validated words found during the current game match.
public struct WordHistorySheet: View {
    public let words: [FoundWord]
    public let theme: GameTheme
    public let onDismiss: () -> Void
    
    public init(
        words: [FoundWord],
        theme: GameTheme,
        onDismiss: @escaping () -> Void
    ) {
        self.words = words
        self.theme = theme
        self.onDismiss = onDismiss
    }
    
    private var totalPoints: Int {
        words.reduce(0) { $0 + $1.points }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(theme.sceneBackgroundColor)
                    .ignoresSafeArea()
                
                if words.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Words Found Yet")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Connect 3 or more adjacent letters on the 3D cube to spell words.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                Text("Total Score")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Spacer()
                                Text("\(totalPoints) pts")
                                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                                    .foregroundColor(theme.accentColor)
                            }
                        }
                        
                        Section(header: Text("Words Found (\(words.count))")) {
                            ForEach(words) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.word)
                                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("\(item.word.count) letters • \(String(format: "%.1fx", item.multiplier)) combo")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(item.points)")
                                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Word History")
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
