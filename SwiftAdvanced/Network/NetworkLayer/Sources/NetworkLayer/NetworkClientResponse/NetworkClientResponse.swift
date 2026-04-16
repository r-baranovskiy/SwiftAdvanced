import Foundation

public enum NetworkClientServerResponse: Error
{
    case informationResponse(code: Int)
    case successResponse(code: Int)
    case redirectionMessage(code: Int)
    case clientError(code: Int)
    case serverError(code: Int)
    case unknown(code: Int)
    
    var statusCode: Int {
        switch self {
        case let .informationResponse(code),
            let .successResponse(code),
            let .redirectionMessage(code),
            let .clientError(code),
            let .serverError(code),
            let .unknown(code):
            return code
        }
    }
    
    init(urlReponse: HTTPURLResponse) {
        let statusCode = urlReponse.statusCode
        switch statusCode {
        case 100...199: self = .informationResponse(code: statusCode)
        case 200...299: self = .successResponse(code: statusCode)
        case 300...399: self = .redirectionMessage(code: statusCode)
        case 400...499: self = .clientError(code: statusCode)
        case 500...599: self = .serverError(code: statusCode)
        default: self = .unknown(code: statusCode)
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
