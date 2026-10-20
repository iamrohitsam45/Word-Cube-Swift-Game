import Foundation
import UIKit

/// High-performance English dictionary validation service combining UIKit's UITextChecker
/// with a fast in-memory fallback vocabulary.
public final class DictionaryService: @unchecked Sendable {
    public static let shared = DictionaryService()
    
    private let textChecker = UITextChecker()
    private var customWordSet: Set<String> = []
    
    public init() {
        loadEmbeddedWordList()
    }
    
    /// Loads common words from bundled resource if available.
    private func loadEmbeddedWordList() {
        if let url = Bundle.main.url(forResource: "words_common", withExtension: "txt"),
           let data = try? String(contentsOf: url, encoding: .utf8) {
            let words = data.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { $0.count >= 3 }
            self.customWordSet = Set(words)
        }
    }
    
    /// Validates if a given word string is a legitimate English word of at least 3 letters.
    public func isValidWord(_ rawWord: String) -> Bool {
        let word = rawWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard word.count >= 3 else { return false }
        
        // 1. Fast check against bundled vocabulary if present
        if customWordSet.contains(word) {
            return true
        }
        
        // 2. UIKit system dictionary verification
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
}
