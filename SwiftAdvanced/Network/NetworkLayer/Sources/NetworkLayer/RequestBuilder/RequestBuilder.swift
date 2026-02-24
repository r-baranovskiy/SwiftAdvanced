import Foundation

public protocol IRequestBuilder: AnyObject
{
    func buid() -> URLRequest
    func httpMethod(_ method: HTTPMethod) -> Self
    func addHeader(_ key: String, value: String) -> Self
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

    public func buid() -> URLRequest {
        guard var url = URL(string: baseURL) else {
            fatalError("Bad URL")
        }

        if let path = self.config.path {
            url = url.appending(path: path)
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = self.config.headers
        request.httpMethod = self.config.method.rawValue
        return request
    }
}
