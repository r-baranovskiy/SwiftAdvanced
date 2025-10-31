import Foundation

public protocol INetworkLayer {
    func request<T: Codable>(
        sesstion: URLSession,
        _ endpoint: IEndpoint,
        type: T.Type
    ) async throws -> T
}

public final class NetworkLayer {
    private let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
}

// MARK: - INetworkLayer

extension NetworkLayer: INetworkLayer {
    public func request<T: Codable>(
        sesstion: URLSession,
        _ endpoint: IEndpoint,
        type: T.Type
    ) async throws -> T {
        guard let request = buildRequest(endpoint: endpoint) else {
            throw NetworkLayerError.badRequest
        }
        let (data, response) = try await sesstion.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              (200...300) ~= response.statusCode else {
            let statusCode = (response as! HTTPURLResponse).statusCode
            throw NetworkLayerError.invalidStatusCode(code: statusCode)
        }
        
        return try await processingDecode(for: data, type)
    }
}

// MARK: - Private

private extension NetworkLayer {
    func buildRequest(endpoint: IEndpoint) -> URLRequest? {
        guard let url = endpoint.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.name
        switch endpoint.method {
        case .GET:
            break
        case .POST(data: let data):
            request.httpBody = data
        }
        
        return request
    }
    
    func processingDecode<T: Decodable>(
        for data: Data, _ type: T.Type
    ) async throws -> T {
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch let DecodingError.keyNotFound(key, context) {
            throw NetworkLayerError.decodingError(
                description: "Missing key '\(key.stringValue)' in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            )
        } catch let DecodingError.typeMismatch(type, context) {
            throw NetworkLayerError.decodingError(
                description: "Type mismatch for type \(type) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            )
        } catch let DecodingError.valueNotFound(type, context) {
            throw NetworkLayerError.decodingError(
                description: "Value not found for type \(type) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            )
        } catch {
            throw NetworkLayerError.decodingError(
                description: "Failed to decode \(T.self): \(error.localizedDescription)"
            )
        }
    }
}
