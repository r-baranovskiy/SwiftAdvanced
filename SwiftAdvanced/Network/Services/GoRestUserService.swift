import Foundation
import NetworkLayer

protocol IGoRestUserService
{
    func start() async
}

private extension GoRestUserService
{
    enum Constants
    {
        static let baseURL: String = "https://gorest.co.in/public/v2"
        static let accessToken: String = ""
    }
}

final class GoRestUserService: IGoRestUserService
{
    private let requestBuilder: IRequestBuilder
    private let logger: INetworkClientLogger
    private let client: INetworkClient

    init() {
        self.requestBuilder = RequestBuilder(baseURL: Constants.baseURL)
        self.logger = NetworkClientLogger()
        self.client = NetworkClient()
    }

    func start() async {
        await fetchUsers()
        if let user = await createUser() {
            debugPrint(user)
            if let newUser = await editUser(id: user.id!) {
                debugPrint(newUser)
                if let deletedUser = await deleteUser(id: newUser.id!) {
                    debugPrint(deletedUser)
                }
            }
        }
    }
}

private extension GoRestUserService
{
    func fetchUsers() async {
        do {
            let request = try self.requestBuilder
                .httpMethod(.get)
                .contentType(.json)
                .authorizationBearer(Constants.accessToken)
                .path("/users")
                .buid()
            let users: [User] = try await self.client
                .request(for: request, with: self.logger)
                .prepareData()
            debugPrint(users)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func createUser() async -> User? {
        let user = User(name: "Ruslan", email: "createdRus@yandex.com", gender: "male", status: "active")

        do {
            let data = try JSONEncoder().encode(user)
            let request = try self.requestBuilder
                .httpMethod(.post)
                .contentType(.json)
                .authorizationBearer(Constants.accessToken)
                .addHeader("Accept", value: "application/json")
                .path("/users")
                .body(data)
                .buid()
            let user: User = try await self.client
                .request(for: request, with: self.logger)
                .prepareData()
            return user
        } catch let error as StatusCodeError {
            if case .clientError(let code) = error {
                debugPrint(error.localizedDescription + " \(code)")
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }

    func editUser(id: Int) async -> User? {
        let user = User(name: "Ruslannnn", email: "editedRus@yandex.com", gender: "female", status: "active")

        do {
            let data = try JSONEncoder().encode(user)
            let request = try self.requestBuilder
                .httpMethod(.put)
                .contentType(.json)
                .authorizationBearer(Constants.accessToken)
                .addHeader("Accept", value: "application/json")
                .path("/users/\(id)")
                .body(data)
                .buid()
            let user: User = try await self.client
                .request(for: request, with: self.logger)
                .prepareData()
            return user
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }

    func deleteUser(id: Int) async -> String? {
        do {
            let request = try self.requestBuilder
                .httpMethod(.delete)
                .contentType(.json)
                .authorizationBearer(Constants.accessToken)
                .addHeader("Accept", value: "application/json")
                .path("/users/\(id)")
                .buid()
            let response = try await self.client.request(for: request, with: self.logger)
            if case .successResponse(_, let data) = response {
                return String(data: data, encoding: .utf8)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
}

struct User: Codable
{
    var id: Int?
    let name: String
    let email: String
    let gender: String
    let status: String
}
