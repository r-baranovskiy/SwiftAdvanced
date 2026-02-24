import Foundation

struct RequestConfig
{
    var path: String?
    var headers: [String: String] = [:]
    var method: HTTPMethod = .GET
}
