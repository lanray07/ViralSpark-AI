import Foundation

struct MockAIService: AIGenerating {
    func generate(request: AIRequest) async throws -> AIResponse {
        try await Task.sleep(for: .milliseconds(700))

        switch request.kind {
        case .hook:
            return AIResponse(result: hookResponse(for: request))
        case .script:
            return AIResponse(result: scriptResponse(for: request))
        case .caption:
            return AIResponse(result: captionResponse(for: request))
        case .hashtags:
            return AIResponse(result: hashtagResponse(for: request))
        case .calendar:
            return AIResponse(result: calendarResponse(for: request))
        case .trendAngles:
            return AIResponse(result: trendAngleResponse(for: request))
        }
    }

    private func hookResponse(for request: AIRequest) -> String {
        (1...10).map { index in
            let score = 94 - index
            return """
            \(index). \(request.topic): the mistake most \(request.audience.isEmpty ? "creators" : request.audience) make before they start
            Score: \(score)/100
            Why it works: It opens a curiosity gap, names a specific audience, and promises a fast payoff for \(request.platform).
            """
        }
        .joined(separator: "\n\n")
    }

    private func scriptResponse(for request: AIRequest) -> String {
        """
        Hook
        Stop scrolling if \(request.topic.lowercased()) has ever felt harder than it should.

        Main points
        1. Name the common mistake.
        2. Show the simple shift.
        3. Give one example the viewer can copy today.

        Scene-by-scene script
        0-3s: Face camera. "Most people are doing \(request.topic) backwards."
        4-12s: Show the old way with on-screen text.
        13-24s: Reveal the better method in three steps.
        25-\(request.length): Show a quick before/after and invite action.

        Caption
        Save this before your next post. This is the simpler way to approach \(request.topic).

        CTA
        Comment "SPARK" and I will send the checklist.

        Hashtags
        #ContentStrategy #CreatorTips #ShortFormVideo #MarketingTips #ViralSparkAI
        """
    }

    private func captionResponse(for request: AIRequest) -> String {
        """
        Short caption
        The faster way to make \(request.topic) click.

        Long caption
        If \(request.topic) feels complicated, start here. Keep the idea simple, make the payoff obvious, and give people one reason to save the post.

        CTA caption
        Want the exact framework? Comment "SPARK" and save this for later.

        Hashtag set
        #CreatorEconomy #SmallBusinessMarketing #ContentIdeas #\(request.platform.replacingOccurrences(of: " ", with: "")) #ViralSparkAI
        """
    }

    private func hashtagResponse(for request: AIRequest) -> String {
        """
        Broad
        #Marketing #ContentCreation #SocialMediaTips #CreatorTips

        Niche
        #\(request.topic.replacingOccurrences(of: " ", with: "")) #ShortFormStrategy #ReelsTips #TikTokGrowth

        Community
        #CreatorsOfInstagram #SmallBusinessOwner #FreelancerLife #CoachMarketing

        Intent
        #LeadGeneration #ContentThatConverts #BrandGrowth #ViralSparkAI
        """
    }

    private func calendarResponse(for request: AIRequest) -> String {
        """
        \(request.length) Posting Plan for \(request.topic)

        Day 1: Pain point hook
        Angle: The hidden reason your audience ignores this topic.
        CTA: Save this checklist.

        Day 2: Myth-busting
        Angle: A belief about \(request.topic) that slows people down.
        CTA: Share with someone who needs this.

        Day 3: Tutorial
        Angle: Three practical steps to get a cleaner result.
        CTA: Comment "PLAN" for the template.

        Day 4: Story
        Angle: A personal lesson that makes the advice memorable.
        CTA: Follow for tomorrow's breakdown.

        Day 5: Comparison
        Angle: Old way versus better way.
        CTA: Save before your next post.

        Day 6: Mistake
        Angle: The most common mistake and how to fix it.
        CTA: Try this today.

        Day 7: Checklist
        Angle: The pre-post checklist that improves retention.
        CTA: Bookmark this workflow.
        """
    }

    private func trendAngleResponse(for request: AIRequest) -> String {
        let count = Int(request.length) ?? 20
        let categories = [
            "Pain point", "Myth-busting", "Tutorial", "Story", "Comparison",
            "Mistake", "Checklist", "Unpopular opinion"
        ]

        return (1...count).map { index in
            let category = categories[(index - 1) % categories.count]
            return "\(index). [\(category)] A \(request.platform.isEmpty ? "short-form" : request.platform) angle about \(request.topic) that creates curiosity and gives viewers one clear takeaway."
        }
        .joined(separator: "\n")
    }
}
