import Foundation

public protocol IRequestBuilder: AnyObject
{
    func buid() throws -> URLRequest
    func httpMethod(_ method: HTTPMethod) -> Self
    func addHeader(_ key: String, value: String) -> Self
    func query(_ items: [String: String]) -> Self
    func path(_ path: String) -> Self
}

public final class RequestBuilder
{
    private let baseURL: String
    private var config = RequestConfig()
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
}

extension RequestBuilder: IRequestBuilder
{
    public func httpMethod(_ method: HTTPMethod) -> Self {
        self.config.method = method
        return self
    }

    public func addHeader(_ key: String, value: String) -> Self {
        self.config.headers[key] = value
        return self
    }

    public func path(_ path: String) -> Self {
        self.config.path = path
        return self
    }

    public func query(_ items: [String: String]) -> Self {
        items.forEach {
            config.queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        return self
    }

    public func buid() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkClientError.invalidURL
        }

        if let path = config.path {
            components.path.append(path)
        }

        if !config.queryItems.isEmpty {
            components.queryItems = config.queryItems
        }

        guard let url = components.url else {
            throw NetworkClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = self.config.headers
        request.httpMethod = self.config.method.rawValue
        return request
    }
}
