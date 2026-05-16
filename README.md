# ViralSpark AI

ViralSpark AI is a SwiftUI iOS app for short-form creators, coaches, freelancers, small businesses, and marketers. It generates hooks, scripts, captions, hashtag sets, trend angles, and content plans with local persistence and a freemium StoreKit 2 subscription structure.

## Open In Xcode

Open:

```text
ViralSparkAI.xcodeproj
```

The app targets iOS 17+ and uses:

- SwiftUI
- SwiftData
- StoreKit 2
- UserNotifications for local content reminders
- Mock AI responses by default

## AI Backend

No AI provider keys are stored in the app.

Mock AI is enabled in `ViralSparkAI/Utilities/AppConfiguration.swift`:

```swift
static let useMockAI = true
```

To use live AI:

1. Set `useMockAI` to `false`.
2. Replace `backendEndpoint` with your secure backend URL.
3. Implement the backend endpoint:

```http
POST https://YOUR_BACKEND_URL.com/generate
Content-Type: application/json
```

Request body:

```json
{
  "type": "hook/script/caption/hashtags/calendar",
  "topic": "",
  "platform": "",
  "tone": "",
  "audience": "",
  "length": ""
}
```

Response body:

```json
{
  "result": ""
}
```

## StoreKit Products

The app expects these auto-renewable subscription product IDs:

- `com.viralsparkai.pro.weekly`
- `com.viralsparkai.pro.monthly`
- `com.viralsparkai.pro.yearly`

Placeholder pricing:

- Weekly: £4.99
- Monthly: £14.99
- Yearly: £99.99

## App Store Readiness

Placeholder review-facing content is included under `ViralSparkAI/Resources` and mirrored in Settings:

- Privacy Policy
- Terms of Use
- AI Disclaimer
- Subscription Explanation
- Safety & Moderation Notice

Before submission, replace placeholders with final legal text, configure real StoreKit products in App Store Connect, add server-side moderation to the backend, and update the bundle identifier/team signing settings.
