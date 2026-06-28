import Foundation

public enum NetworkClientResponse
{
    case informationResponse(code: Int)
    case successResponse(code: Int, data: Data)
    case redirectionMessage(code: Int)
    case error(NetworkClientError)

    var statusCode: Int? {
        switch self {
        case let .informationResponse(code),
            let .successResponse(code, _),
            let .redirectionMessage(code):
            return code
        case let .error(error):
            if case .codeError(let codeError) = error {
                switch codeError {
                case let .clientError(code),
                    let .serverError(code),
                    let .unknown(code):
                    return code
                }
            }
        }
        return nil
    }

    var description: String {
        switch self {
        case .informationResponse(let code):
            "Information Response: \(code)"
        case .successResponse(let code, _):
            "Success Response: \(code)"
        case .redirectionMessage(let code):
            "Redirection Message: \(code)"
        case .error(let networkClientError):
            networkClientError.errorDescription ?? ""
        }
    }

    init(urlReponse: HTTPURLResponse, data: Data) {
        let statusCode = urlReponse.statusCode
        switch statusCode {
        case 100...199: self = .informationResponse(code: statusCode)
        case 200...299: self = .successResponse(code: statusCode, data: data)
        case 300...399: self = .redirectionMessage(code: statusCode)
        default: self = .error(.codeError(error: StatusCodeError(statusCode: statusCode)))
        }
    }

    public func prepareData<T: Decodable>(
        with decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        switch self {
        case .informationResponse, .redirectionMessage:
            throw NetworkClientError.decodingError(error: .default(description: description))
        case .successResponse(_, let data):
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkClientError.decodingError(error: .default(description: "Failed to decode \(T.self): \(error.localizedDescription)"))
            }
        case .error(let networkClientError):
            throw networkClientError
        }
    }
}

extension NetworkClientResponse
{
    public static func == (lhs: NetworkClientResponse, rhs: NetworkClientResponse) -> Bool {
        return lhs.statusCode == rhs.statusCode
    }
}
