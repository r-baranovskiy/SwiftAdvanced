import XCTest
@testable import SwiftAdvanced

final class OperatorTests: XCTestCase {
    func test_operator_return_correct_resul() {
        // Given
        let expected = 11
        
        // When
        let result = 5
        |> { $0 * 2 }
        |> { $0 + 1 }
        
        // Then
        XCTAssertEqual(expected, result)
    }
    
    func test_composition_operator_return_correct_result() {
        // Given
        let increment: (Int) -> Int = { $0 + 1 }
        let double: (Int) -> Int = { $0 * 2 }
        let incrementAndDouble = increment >>> double
        
        // When
        let result = incrementAndDouble(5)
        
        // Then
        XCTAssertEqual(result, 12)
    }
    
    func test_composition_operator_two_func_return_correct_result() {
        // Given
        var result: Int?
        
        
        // When
        result = (increment >>> square)(2)
        
        // Then
        XCTAssertEqual(result, 9)
    }
    
    func test_forward_composition_return_correct_result() {
        // When
        let result = 2 |> increment >>> square
        
        // Then
        XCTAssertEqual(result, 9)
    }
    
    func test_map_array_increment_and_square() {
        // Given
        let array = [1, 2, 3]
        
        // When
        let result = array
            .map(increment)
            .map(square)
        
        // Then
        XCTAssertEqual(result, [4, 9, 16])
    }
    
    func test_map_array_composition() {
        // Given
        let array = [1, 2, 3]
        
        // When
        let result = array
            .map(increment >>> square)
        
        // Then
        XCTAssertEqual(result, [4, 9, 16])
    }
}

private extension OperatorTests
{
    func square(_ x: Int) -> Int {
        return x * x
    }
    
    func increment(_ x: Int) -> Int {
        return x + 1
    }
}
