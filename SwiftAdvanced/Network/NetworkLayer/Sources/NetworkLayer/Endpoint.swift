import Foundation

public protocol IEndpoint {
    var host: String { get }
    var path: String { get }
    var method: MethodType { get }
    var queryItems: [String: String]? { get }
    var url: URL? { get }
}

public enum MethodType: Equatable
{
    case GET
    case POST(data: Data?)
    
    var name: String {
        switch self {
        case .GET:
            "GET"
        case .POST:
            "POST"
        }
    }
}
