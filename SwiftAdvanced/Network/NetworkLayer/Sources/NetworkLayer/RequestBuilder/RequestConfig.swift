import Foundation

struct RequestConfig
{
    var path: String?
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var method: HTTPMethod = .GET
}
