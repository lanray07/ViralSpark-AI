import Foundation

enum PromptTemplateFactory {
    static let systemPrompt = """
    You are ViralSpark AI, an expert short-form content strategist. Generate content that is practical, punchy, platform-native, and designed for retention. Avoid making false claims. Do not generate harmful, hateful, adult, illegal, or misleading content. Structure the answer clearly.
    """

    static func prompt(for request: AIRequest, count: Int? = nil) -> String {
        let targetCount = count.map { "\($0)" } ?? defaultCount(for: request.kind)

        switch request.kind {
        case .hook:
            return """
            \(systemPrompt)

            Generate \(targetCount) viral hook options.
            Topic: \(request.topic)
            Platform: \(request.platform)
            Tone: \(request.tone)
            Audience: \(request.audience)

            Score each hook out of 100 and explain why it works.
            """
        case .script:
            return """
            \(systemPrompt)

            Generate a \(request.length) short-form video script.
            Topic: \(request.topic)
            Audience: \(request.audience)
            Platform: \(request.platform)
            Goal: \(request.tone)

            Use this format: Hook, Main points, Scene-by-scene script, Caption, CTA, Hashtags.
            """
        case .caption:
            return """
            \(systemPrompt)

            Generate short, long, and CTA caption options.
            Video topic: \(request.topic)
            Platform: \(request.platform)
            Tone: \(request.tone)
            Include a relevant hashtag set.
            """
        case .hashtags:
            return """
            \(systemPrompt)

            Generate a platform-native hashtag set.
            Topic: \(request.topic)
            Platform: \(request.platform)
            Audience: \(request.audience)
            Include broad, niche, community, and intent hashtags.
            """
        case .calendar:
            return """
            \(systemPrompt)

            Create a \(request.length) content plan.
            Focus: \(request.topic)
            Platform: \(request.platform)
            Audience: \(request.audience)
            Tone: \(request.tone)
            Include daily topics, angles, captions, CTAs, and production notes.
            """
        case .trendAngles:
            return """
            \(systemPrompt)

            Generate \(targetCount) short-form content angles for this topic or niche: \(request.topic).
            Include these categories: pain point, myth-busting, tutorial, story, comparison, mistake, checklist, unpopular opinion.
            """
        }
    }

    private static func defaultCount(for kind: GenerationKind) -> String {
        switch kind {
        case .hook:
            return "10"
        case .trendAngles:
            return "20"
        case .hashtags:
            return "30"
        case .script, .caption, .calendar:
            return "1"
        }
    }
}
