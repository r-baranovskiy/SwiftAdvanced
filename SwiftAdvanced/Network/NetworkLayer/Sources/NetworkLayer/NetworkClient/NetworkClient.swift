import Foundation

public protocol INetworkClient: AnyObject
{
    /// Выполняет сетевой запрос и возвращает сырые данные.
    ///
    /// Метод отправляет HTTP-запрос, проверяет статус-код ответа и, в случае успеха (2xx),
    /// возвращает полученные данные. В случае ошибки выбрасывает соответствующее исключение.
    ///
    /// - Parameters:
    ///   - request: `URLRequest` с настроенными заголовками, методом и телом запроса
    ///   - logger: Опциональный логгер для логирования запроса в формате cURL.
    ///             Если передан, метод залогирует запрос через `logger.logCurl(from:)`
    ///
    /// - Returns: Сырые `Data` из тела ответа сервера при успешном запросе (статус-код 2xx)
    ///
    /// - Throws: `NetworkClientError` при различных ошибках выполнения запроса:
    ///   - `.badResponse` — если ответ сервера не является HTTP-ответом
    ///   - `.NetworkCodeError(statusCode:)` — для статус-кодов вне диапазона 2xx (200-299)
    ///   - `.transportError(TransportError)` — при сетевых ошибках:
    ///     - `.offline` — нет подключения к интернету
    ///     - `.timeout` — таймаут запроса
    ///     - `.tlsFailure` — ошибка SSL/TLS сертификата
    ///     - `.dnsFailure` — не удалось разрешить DNS-имя
    ///     - `.cannotConnect` — не удалось подключиться к хосту
    ///     - `.cancelled` — запрос был отменен
    ///     - `.unknown` — неизвестная сетевая ошибка
    func request(for request: URLRequest,
                 with logger: INetworkClientLogger?) async throws -> NetworkClientResponse
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
    public func request(for request: URLRequest,
                        with logger: INetworkClientLogger?) async throws -> NetworkClientResponse {
        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkClientError.badResponse
            }
            let clientResponse = NetworkClientResponse(urlReponse: response, data: data)

            if let logger {
                logger.logCurl(from: request)
            }

            return clientResponse
        } catch let error as URLError {
            throw self.prepareUrlError(from: error)
        }
    }
}

// MARK: - Private
private extension NetworkClient {
    func prepareUrlError(
        from error: URLError
    ) -> TransportError {
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
