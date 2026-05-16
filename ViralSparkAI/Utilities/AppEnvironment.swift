import SwiftUI

private struct AIServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: any AIGenerating = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIGenerating {
        get { self[AIServiceEnvironmentKey.self] }
        set { self[AIServiceEnvironmentKey.self] = newValue }
    }
}
