import SwiftUI

enum PolicyDocument: String, CaseIterable, Identifiable {
    case privacy
    case terms
    case aiDisclosure
    case subscription
    case safety

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy:
            return "Privacy Policy"
        case .terms:
            return "Terms of Use"
        case .aiDisclosure:
            return "AI Disclosure"
        case .subscription:
            return "Subscription Details"
        case .safety:
            return "Safety & Moderation"
        }
    }

    var systemImage: String {
        switch self {
        case .privacy:
            return "hand.raised.fill"
        case .terms:
            return "doc.text.fill"
        case .aiDisclosure:
            return "sparkles"
        case .subscription:
            return "crown.fill"
        case .safety:
            return "checkmark.shield.fill"
        }
    }

    var bodyText: String {
        switch self {
        case .privacy:
            return """
            ViralSpark AI stores your profile choices, generated content, saved library items, and content plans locally on your device using SwiftData.

            If live AI is enabled, generation requests are sent to the configured secure backend endpoint. Do not send sensitive personal, financial, medical, legal, or confidential information in prompts.

            The iOS app does not contain OpenAI API keys. Any third-party AI provider keys must remain on a backend you control.

            You can delete locally saved data from Settings at any time.
            """
        case .terms:
            return """
            ViralSpark AI provides drafting and planning tools for short-form content. Outputs are suggestions and may require editing, fact-checking, and brand review before use.

            You are responsible for the content you publish and for ensuring that your posts comply with platform rules, applicable laws, advertising standards, and intellectual property rights.

            Subscriptions are handled by Apple using StoreKit. Paid features remain available while your subscription is active.
            """
        case .aiDisclosure:
            return """
            ViralSpark AI uses artificial intelligence to generate hooks, scripts, captions, hashtag sets, content ideas, and posting plans.

            AI-generated content can be inaccurate, incomplete, repetitive, or unsuitable for your audience. Review and edit every output before posting.

            The app is designed to avoid harmful, hateful, adult, illegal, or misleading content. Unsafe requests may be refused or produce a safety-oriented response.
            """
        case .subscription:
            return """
            Free plan:
            - 5 generations per day
            - Limited templates
            - Exported text includes "Generated with ViralSpark AI"

            Pro plan:
            - Unlimited generations
            - Advanced hooks
            - Content calendar
            - Saved library
            - Export scripts
            - Premium templates
            - Batch content generation

            Placeholder pricing:
            Weekly: £4.99
            Monthly: £14.99
            Yearly: £99.99

            Subscriptions automatically renew unless cancelled in Apple ID settings at least 24 hours before the end of the current billing period.
            """
        case .safety:
            return """
            ViralSpark AI is for lawful, safe, creator-friendly marketing and educational content.

            Do not use the app to create harassment, hate, explicit adult content, illegal instructions, scams, impersonation, medical/legal/financial claims without review, or misleading advertising.

            If you connect a backend AI provider, add server-side moderation and logging appropriate for your market, privacy obligations, and App Review requirements.
            """
        }
    }
}

struct PolicyDocumentView: View {
    let document: PolicyDocument

    var body: some View {
        ScrollView {
            SparkCard(padding: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: document.systemImage)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.purple)
                        .frame(width: 64, height: 64)
                        .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text(document.title)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    Text(document.bodyText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}
