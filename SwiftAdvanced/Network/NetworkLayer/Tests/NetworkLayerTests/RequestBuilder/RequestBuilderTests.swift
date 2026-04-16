import XCTest
@testable import NetworkLayer

final class RequestBuilderTests: XCTestCase
{
    /**
     Тест проверяет, что реквест корректно создается с HTTP методом `GET`
    */
    func test_makeRequest_withHttpMethodGET_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "GET")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .httpMethod(.GET)
                .buid()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается с HTTP методом `POST`
    */
    func test_makeRequest_withHttpMethodPOST_correctCreated() {
        // Given
        let env = Environment()
        
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "POST")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .httpMethod(.POST)
                .buid()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если к URL добавить `path`
    */
    func test_makeRequest_withPath_correctCreated() {
        // Given
        let env = Environment()
        let expectedURL = TestFactory.baseURL("/pictures")
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedRequest = TestFactory.makeRequest(url: expectedURL, HTTPMethod: "GET")
        var request: URLRequest?

        // When
        do {
            request = try sut
                .path("pictures")
                .buid()
        } catch {
            XCTFail(error.localizedDescription)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }

    /**
     Тест проверяет, что реквест корректно создается если добавить `Headers`
    */
    func test_makeRequest_withHeaders_correctCreated() {
        // Given
        let env = Environment()
        let sut = env.makeSut(TestFactory.baseURL())
        let expectedHeaders = ["API_Key": "123456",
                               "Content-Type": "application/json"]
        let expectedRequest = TestFactory.makeRequest(url: TestFactory.baseURL(),
                                                      HTTPMethod: "GET",
                                                      headers: expectedHeaders)
        var request: URLRequest?

        // When
        do {
            request = try sut
                .addHeader("API_Key", value: "123456")
                .addHeader("Content-Type", value: "application/json")
                .buid()
        } catch {
            XCTAssertEqual(expectedRequest, request)
        }

        // Then
        XCTAssertEqual(expectedRequest, request)
    }
}

private extension RequestBuilderTests
{
    final class Environment
    {
        func makeSut(_ url: URL) -> IRequestBuilder {
            RequestBuilder(baseURL: url.absoluteString)
        }
    }
}

private extension RequestBuilderTests
{
    enum TestFactory
    {
        static func baseURL(_ path: String = "") -> URL {
            let baseURL: URL = URL(string: "https://google.com")!
                .appending(path: path)
            return baseURL
        }

        static func makeRequest(url: URL,
                                HTTPMethod: String,
                                headers: [String: String] = [:]) -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod
            request.allHTTPHeaderFields = headers
            return request
        }
    }
}
