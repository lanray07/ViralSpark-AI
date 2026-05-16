import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ContentCalendarViewModel {
    var focus = ""
    var platform = Platform.instagramReels.rawValue
    var state: LoadingState<String> = .idle
    var notice: String?

    var canGenerate: Bool {
        !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func createPlan(
        days: Int,
        aiService: any AIGenerating,
        usageLimitManager: UsageLimitManager,
        isPro: Bool,
        modelContext: ModelContext
    ) async {
        notice = nil

        guard canGenerate else {
            state = .failed("Add a niche, topic, or campaign focus first.")
            return
        }

        guard days != 30 || isPro else {
            state = .limitReached
            return
        }

        guard usageLimitManager.canGenerate(isPro: isPro) else {
            state = .limitReached
            return
        }

        state = .loading

        let request = AIRequest(
            kind: .calendar,
            topic: focus,
            platform: platform,
            tone: ContentTone.educational.rawValue,
            audience: "",
            length: "\(days)-day"
        )

        do {
            let response = try await aiService.generate(request: request)
            let draft = ContentPlanBuilder.build(
                focus: focus,
                platform: platform,
                days: days,
                aiOutput: response.result
            )

            modelContext.insert(draft.plan)
            draft.posts.forEach { modelContext.insert($0) }

            let generation = GenerationItem(
                type: GenerationKind.calendar.rawValue,
                prompt: PromptTemplateFactory.prompt(for: request),
                output: response.result,
                platform: platform,
                tone: ContentTone.educational.rawValue
            )
            modelContext.insert(generation)

            try modelContext.save()
            usageLimitManager.recordGeneration(isPro: isPro)
            notice = "\(days)-day plan created"
            state = .loaded(response.result)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
