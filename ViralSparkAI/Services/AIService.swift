import Foundation

struct AIRequest: Codable, Equatable {
    var kind: GenerationKind
    var topic: String
    var platform: String
    var tone: String
    var audience: String
    var length: String

    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case topic
        case platform
        case tone
        case audience
        case length
    }
}

struct AIResponse: Codable, Equatable {
    let result: String
}

enum AIServiceError: LocalizedError {
    case invalidResponse
    case unsuccessfulStatus(Int)
    case missingBackend

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The AI response could not be read. Please try again."
        case .unsuccessfulStatus(let statusCode):
            return "The AI service returned status \(statusCode)."
        case .missingBackend:
            return "Connect ViralSpark AI to your secure backend endpoint before using live AI."
        }
    }
}

protocol AIGenerating {
    func generate(request: AIRequest) async throws -> AIResponse
}

struct NetworkAIService: AIGenerating {
    let endpoint: URL
    let session: URLSession

    init(
        endpoint: URL = AppConfiguration.backendEndpoint,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func generate(request: AIRequest) async throws -> AIResponse {
        guard endpoint.host != "YOUR_BACKEND_URL.com" else {
            throw AIServiceError.missingBackend
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.unsuccessfulStatus(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(AIResponse.self, from: data)
    }
}
