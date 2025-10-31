import Foundation

public enum NetworkLayerError: Error, Equatable {
    case invalidURL
    case badRequest
    case decodingError(description: String)
    case invalidStatusCode(code: Int)
}
