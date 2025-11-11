import XCTest
@testable import SwiftAdvanced

final class ServiceLocatorTests: XCTestCase
{
    func test_success_register_service() {
        // Given
        let env = Environment()
        let sut = env.makeSut()
        protocol ITestService { }
        final class TestService: ITestService { }

        // When
        sut.register(service: TestService() as ITestService)

        // Then
        XCTAssertEqual(sut.services.count, 1)
    }

    func test_success_register_some_services() {
        let env = Environment()
        let sut = env.makeSut()

        protocol IFirstService { }
        protocol ISecondService { }

        final class FirstService: IFirstService { }
        final class SecondService: ISecondService { }

        // When
        sut.register(service: FirstService() as IFirstService)
        sut.register(service: SecondService() as ISecondService)

        // Then
        XCTAssertEqual(sut.services.count, 2)
    }

    func test_correct_resolve_service() {
        let env = Environment()
        let sut = env.makeSut()

        protocol IFirstService { }

        final class FirstService: IFirstService { }

        // When
        sut.register(service: FirstService() as IFirstService)
        let service: IFirstService = sut.resolve()

        // Then
        XCTAssertTrue(service is FirstService)
    }

    func test_correct_inject_service() {
        let env = Environment()
        let sut = env.makeSut()

        protocol IFirstService { }

        final class FirstService: IFirstService { }

        // When
        sut.register(service: FirstService() as IFirstService)

        @Inject
        var service: IFirstService

        // Then
        XCTAssertTrue(service is FirstService)
    }

    func test_success_clear_all_services() {
        let env = Environment()
        let sut = env.makeSut()

        protocol IFirstService { }
        protocol ISecondService { }

        final class FirstService: IFirstService { }
        final class SecondService: ISecondService { }

        // When
        sut.register(service: FirstService() as IFirstService)
        sut.register(service: SecondService() as ISecondService)
        sut.clear()

        // Then
        XCTAssertEqual(sut.services.count, 0)
    }

    func test_success_remove_service() {
        let env = Environment()
        let sut = env.makeSut()

        protocol IFirstService { }
        protocol ISecondService { }

        final class FirstService: IFirstService { }
        final class SecondService: ISecondService { }

        // When
        sut.register(service: FirstService() as IFirstService)
        sut.register(service: SecondService() as ISecondService)
        let deletedService: IFirstService = sut.resolve()
        sut.removeService(deletedService)

        // Then
        XCTAssertEqual(sut.services.count, 1)
        XCTAssertTrue(sut.services.first?.value is SecondService)
    }
}

private extension ServiceLocatorTests
{
    final class Environment
    {
        func makeSut() -> ServiceLocator {
            ServiceLocator.shared.clear()
            return ServiceLocator.shared
        }
    }
}
