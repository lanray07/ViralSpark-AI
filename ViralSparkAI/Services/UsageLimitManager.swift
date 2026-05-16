import Foundation
import Observation

@MainActor
@Observable
final class UsageLimitManager {
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let dateFormatter: DateFormatter

    var usageCount: Int = 0

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
        self.dateFormatter = DateFormatter()
        self.dateFormatter.calendar = calendar
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        refresh()
    }

    var dailyLimit: Int {
        AppConfiguration.dailyFreeGenerationLimit
    }

    func refresh() {
        usageCount = defaults.integer(forKey: usageKey(for: .now))
    }

    func remainingGenerations(isPro: Bool) -> Int? {
        guard !isPro else { return nil }
        return max(dailyLimit - usageCount, 0)
    }

    func canGenerate(isPro: Bool) -> Bool {
        refresh()
        return isPro || usageCount < dailyLimit
    }

    func recordGeneration(isPro: Bool) {
        guard !isPro else { return }
        refresh()
        usageCount += 1
        defaults.set(usageCount, forKey: usageKey(for: .now))
    }

    private func usageKey(for date: Date) -> String {
        "usage.generations.\(dateFormatter.string(from: date))"
    }
}
