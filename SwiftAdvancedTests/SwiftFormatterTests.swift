import XCTest
@testable import SwiftAdvanced

final class SwiftFormatterTests: XCTestCase {
    func test_format_decimal_and_round_up() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        
        // When
        let result = sut.wholeStyle(sut.decimalStyle(env.config))
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 235")
    }

    func test_format_currency_and_round_down() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        var config = env.config
        config.roundingMode = .down
        
        // When
        let result = sut.wholeStyle(sut.currencyStyle(config))
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 234 $")
    }

    func test_inout_format_decimal_and_round_up() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        var config = env.config
        
        // When
        sut.inoutDecimalStyle(&config)
        sut.inoutWholeStyle(&config)
        let result = config
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 235")
    }

    func test_inout_format_currency_and_round_down() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        var config = env.config
        config.roundingMode = .down
        
        // When
        sut.inoutWholeStyle(&config)
        sut.inoutCurrencyStyle(&config)
        let result = config
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 234 $")
    }
    
    func test_format_decimal_and_round_up_with_composition() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        let config = env.config
        
        // When
        let composition = config |> sut.decimalStyle <> sut.wholeStyle
        let result = composition
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 235")
    }
    
    func test_format_currency_and_round_down_with_inout_composition() {
        // Given
        let env = Environment()
        let sut = env.makeSUT()
        var config = env.config
        config.roundingMode = .down
        
        // When
        let composition = config |> sut.inoutWholeStyle <> sut.inoutCurrencyStyle
        let result = composition
            .formatter
            .string(for: 1234.6)
        
        // Then
        XCTAssertEqual(result, "1 234 $")
    }
}

private extension SwiftFormatterTests
{
    final class Environment
    {
        var config: CustomFormatter.NumberFormatterConfig {
            CustomFormatter.NumberFormatterConfig()
        }
        func makeSUT() -> CustomFormatter {
            CustomFormatter()
        }
    }
}
