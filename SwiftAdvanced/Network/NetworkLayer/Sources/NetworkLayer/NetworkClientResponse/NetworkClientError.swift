import Foundation

public enum NetworkClientError: Error
{
    case invalidURL
    case badResponse
    case decodingError(description: String)
    case transportError(error: TransportError)
    case codeError(error: NetworkCodeError)

    public enum TransportError: Error
    {
        case offline, timeout, dnsFailure, cannotConnect, cancelled,tlsFailure, unknown
    }

    public enum NetworkCodeError: Error, Equatable
    {
        case clientError(code: Int)
        case serverError(code: Int)
        case unknown(code: Int)

        init(statusCode: Int) {
            switch statusCode {
            case 400...499: self = .clientError(code: statusCode)
            case 500...599: self = .serverError(code: statusCode)
            default: self = .unknown(code: statusCode)
            }
        }
    }
}

extension NetworkClientError: LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badResponse: return "Bad response"
        case .decodingError(description: let description): return "Decoding error: \(description)"
        case .transportError(error: let error): return "Transport error: \(error)"
        case .codeError(error: let error): return "Code error: \(error)"
        }
    }
}

extension NetworkClientError: Equatable
{
    public static func == (lhs: NetworkClientError, rhs: NetworkClientError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.badResponse, .badResponse):
            return true
        case (.decodingError, .decodingError):
            return true
        case let (.transportError(lhsError), .transportError(rhsError)):
            return lhsError == rhsError
        case let (.codeError(lhsError), .codeError(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
