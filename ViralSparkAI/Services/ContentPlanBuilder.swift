import Foundation

struct ContentPlanDraft {
    let plan: ContentPlan
    let posts: [PlannedPost]
}

enum ContentPlanBuilder {
    static func build(
        focus: String,
        platform: String,
        days: Int,
        aiOutput: String,
        startDate: Date = .now,
        calendar: Calendar = .current
    ) -> ContentPlanDraft {
        let plan = ContentPlan(
            title: "\(days)-Day \(platform) Plan",
            focus: focus,
            durationDays: days,
            platform: platform,
            overview: aiOutput
        )

        let postTemplates = makePostTemplates(focus: focus)
        let posts = (0..<days).map { index in
            let template = postTemplates[index % postTemplates.count]
            let scheduledDate = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate

            return PlannedPost(
                planID: plan.id,
                title: "Day \(index + 1): \(template.title)",
                angle: template.angle,
                platform: platform,
                captionDraft: template.caption,
                scheduledDate: scheduledDate
            )
        }

        return ContentPlanDraft(plan: plan, posts: posts)
    }

    private static func makePostTemplates(focus: String) -> [(title: String, angle: String, caption: String)] {
        [
            ("Pain point", "Name the most frustrating blocker around \(focus).", "Most people make \(focus) harder than it needs to be. Start here."),
            ("Myth-busting", "Challenge a belief your audience repeats.", "The common advice about \(focus) misses one important detail."),
            ("Tutorial", "Teach a three-step process.", "Use this quick framework the next time \(focus) is on your content plan."),
            ("Story", "Share a lesson learned from experience.", "A small story about \(focus) can make the advice much easier to remember."),
            ("Comparison", "Show old way versus better way.", "Old way vs better way: here is how to approach \(focus) with less friction."),
            ("Mistake", "Reveal one mistake and the fix.", "Fix this before your next post about \(focus)."),
            ("Checklist", "Give a saveable checklist.", "Save this checklist before you publish content about \(focus).")
        ]
    }
}
