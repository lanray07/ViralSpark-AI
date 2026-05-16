import Foundation
import SwiftData

@Model
final class ContentPlan {
    @Attribute(.unique) var id: UUID
    var title: String
    var focus: String
    var durationDays: Int
    var platform: String
    var overview: String
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        focus: String,
        durationDays: Int,
        platform: String,
        overview: String,
        generatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.focus = focus
        self.durationDays = durationDays
        self.platform = platform
        self.overview = overview
        self.generatedAt = generatedAt
    }
}

@Model
final class PlannedPost {
    @Attribute(.unique) var id: UUID
    var planID: UUID
    var title: String
    var angle: String
    var platform: String
    var captionDraft: String
    var scheduledDate: Date
    var status: String
    var reminderDate: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        planID: UUID,
        title: String,
        angle: String,
        platform: String,
        captionDraft: String,
        scheduledDate: Date,
        status: String = PlannedPostStatus.drafted.rawValue,
        reminderDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.planID = planID
        self.title = title
        self.angle = angle
        self.platform = platform
        self.captionDraft = captionDraft
        self.scheduledDate = scheduledDate
        self.status = status
        self.reminderDate = reminderDate
        self.createdAt = createdAt
    }
}
