import Foundation

public enum NetworkClientError: Error
{
    case invalidURL
    case badResponse
    case decodingError(description: String)
}
