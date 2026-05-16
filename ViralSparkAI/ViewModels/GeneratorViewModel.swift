import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class GeneratorViewModel {
    let tool: GeneratorTool

    var topic = ""
    var platform = Platform.tikTok.rawValue
    var tone = ContentTone.bold.rawValue
    var audience = ""
    var videoLength = VideoLength.thirty.rawValue
    var scriptGoal = ScriptGoal.educate.rawValue
    var planDays = 7
    var contentCount = 20
    var state: LoadingState<String> = .idle
    var lastGeneration: GenerationItem?
    var notice: String?

    init(tool: GeneratorTool) {
        self.tool = tool
        if tool == .plan {
            tone = ContentTone.educational.rawValue
            contentCount = 7
        }
    }

    var canGenerate: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isFavorite: Bool {
        lastGeneration?.isFavorite ?? false
    }

    func generate(
        aiService: any AIGenerating,
        usageLimitManager: UsageLimitManager,
        isPro: Bool,
        modelContext: ModelContext
    ) async {
        notice = nil

        guard canGenerate else {
            state = .failed("Add a topic, niche, or campaign focus first.")
            return
        }

        guard usageLimitManager.canGenerate(isPro: isPro) else {
            state = .limitReached
            return
        }

        if tool == .plan, planDays == 30, !isPro {
            state = .limitReached
            return
        }

        state = .loading

        let request = makeRequest()
        let prompt = PromptTemplateFactory.prompt(for: request, count: contentCount)

        do {
            let response = try await aiService.generate(request: request)
            let generation = GenerationItem(
                type: tool.kind.rawValue,
                prompt: prompt,
                output: response.result,
                platform: request.platform,
                tone: request.tone
            )

            modelContext.insert(generation)
            if tool == .plan {
                let draft = ContentPlanBuilder.build(
                    focus: topic,
                    platform: platform,
                    days: planDays,
                    aiOutput: response.result
                )
                modelContext.insert(draft.plan)
                draft.posts.forEach { modelContext.insert($0) }
            }

            try modelContext.save()
            usageLimitManager.recordGeneration(isPro: isPro)
            lastGeneration = generation
            state = .loaded(response.result)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func saveToLibrary(modelContext: ModelContext) {
        guard let generation = lastGeneration else { return }

        let title = topic.isEmpty ? tool.shortTitle : topic
        let savedContent = SavedContent(
            type: generation.type,
            title: title,
            body: generation.output,
            platform: generation.platform,
            tone: generation.tone,
            tagsData: tagsFromOutput(generation.output).joined(separator: ", "),
            isFavorite: true
        )

        generation.isFavorite = true
        modelContext.insert(savedContent)
        do {
            try modelContext.save()
            notice = "Saved to Library"
        } catch {
            notice = error.localizedDescription
        }
    }

    func toggleFavorite(modelContext: ModelContext) {
        guard let lastGeneration else { return }
        lastGeneration.isFavorite.toggle()
        do {
            try modelContext.save()
        } catch {
            notice = error.localizedDescription
        }
    }

    func exportText(isPro: Bool) -> String {
        guard let lastGeneration else { return "" }
        guard !isPro else { return lastGeneration.output }
        return "\(lastGeneration.output)\n\nGenerated with ViralSpark AI"
    }

    private func makeRequest() -> AIRequest {
        AIRequest(
            kind: tool.kind,
            topic: topic,
            platform: platform,
            tone: tool == .script ? scriptGoal : tone,
            audience: audience,
            length: requestLength
        )
    }

    private var requestLength: String {
        if tool == .plan {
            return "\(planDays)-day"
        }
        if tool == .ideas {
            return "\(contentCount)"
        }
        return videoLength
    }

    private func tagsFromOutput(_ output: String) -> [String] {
        output
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { $0.hasPrefix("#") }
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:")) }
    }
}
