import Foundation

public enum NetworkClientServerResponse
{
    case informationResponse(code: Int)
    case successResponse(code: Int)
    case redirectionMessage(code: Int)
    case error(NetworkClientError.NetworkCodeError)

    var statusCode: Int {
        switch self {
        case let .informationResponse(code),
            let .successResponse(code),
            let .redirectionMessage(code):
            return code
        case let .error(error):
            switch error {
            case let .clientError(code),
                let .serverError(code),
                let .unknown(code):
                return code
            }
        }
    }

    init(urlReponse: HTTPURLResponse) {
        let statusCode = urlReponse.statusCode
        switch statusCode {
        case 100...199: self = .informationResponse(code: statusCode)
        case 200...299: self = .successResponse(code: statusCode)
        case 300...399: self = .redirectionMessage(code: statusCode)
        default: self = .error(NetworkClientError.NetworkCodeError(statusCode: statusCode))
        }
    }
}

extension NetworkClientServerResponse
{
    public static func == (lhs: NetworkClientServerResponse,
                           rhs: NetworkClientServerResponse) -> Bool {
        return lhs.statusCode == rhs.statusCode
    }
}
