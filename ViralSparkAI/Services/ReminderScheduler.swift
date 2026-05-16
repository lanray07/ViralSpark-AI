import Foundation
import UserNotifications

enum ReminderScheduler {
    static func scheduleReminder(for post: PlannedPost, at date: Date) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Film: \(post.title)"
        content.body = post.angle
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "planned-post-\(post.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }
}
