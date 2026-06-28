import Foundation

public protocol INetworkClient: AnyObject
{
    func request<T: Decodable>(for request: URLRequest,
                               with logger: INetworkClientLogger?) async throws -> T
}

public final class NetworkClient
{
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared,
                decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
}

extension NetworkClient: INetworkClient
{
    public func request<T: Decodable>(for request: URLRequest,
                                      with logger: INetworkClientLogger?) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkClientError.badResponse
        }
        let clientResponse = NetworkClientServerResponse(urlReponse: response)

        if let logger {
            logger.logCurl(from: request)
        }

        guard case .successResponse = clientResponse else {
            throw NetworkClientError.NetworkCodeError(statusCode: clientResponse.statusCode)
        }

        return try await self.processingDecode(for: data)
    }
}

// MARK: - Private

private extension NetworkClient {
    func processingDecode<T: Decodable>(
        for data: Data
    ) async throws -> T {
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch let error as DecodingError {
            throw self.prepareDecodingError(for: T.self, and: error)
        } catch let error as URLError {
            throw self.prepareUrlError(from: error)
        }
    }

    func prepareDecodingError<T: Decodable>(
        for type: T.Type, and error: DecodingError
    ) -> NetworkClientError {
        switch error {
        case .typeMismatch(let any, let context):
            NetworkClientError.decodingError(
                description: "Type mismatch for type \(any) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        case .valueNotFound(let any, let context):
            NetworkClientError.decodingError(
                description: "Value not found for type \(any) in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            )
        case .keyNotFound(let codingKey, let context):
            NetworkClientError.decodingError(
                description: "Missing key '\(codingKey.stringValue)' in \(T.self) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            )
        default:
            NetworkClientError.decodingError(
                description: "Failed to decode \(T.self): \(error.localizedDescription)"
            )
        }
    }

    func prepareUrlError(
        from error: URLError
    ) -> NetworkClientError.TransportError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                .offline
        case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateHasUnknownRoot:
                .tlsFailure
        case .timedOut:
                .timeout
        case .dnsLookupFailed, .cannotFindHost:
                .dnsFailure
        case .cannotConnectToHost:
                .cannotConnect
        case .cancelled:
                .cancelled
        default:
                .unknown
        }
    }
}
