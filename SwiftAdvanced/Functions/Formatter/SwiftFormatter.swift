import Foundation

final class CustomFormatter
{
    struct NumberFormatterConfig {
        /*
         Параметр для определения общего стиля форматирования, такого как десятичный, валютный или процентный.
        */
        var numberStyle: NumberFormatter.Style = .none
        /*
         Режим округления чисел. Определяет как числа должны округляться при превышении максимального количества дробных цифр.
        */
        var roundingMode: NumberFormatter.RoundingMode = .up
        /*
         Максимальное количество цифр после десятичного разделителя. Это свойство для ограничения точности дробной части числа. Если установлено значение 0, дробная часть не отображается.
        */
        var maximumFractionDigits: Int = 0
        
        var formatter: NumberFormatter {
            let result = NumberFormatter()
            result.numberStyle = self.numberStyle
            result.roundingMode = self.roundingMode
            result.maximumFractionDigits = self.maximumFractionDigits
            result.currencyCode = "USD"
            return result
        }
    }

    /// Настраивает форматтер для десятичного стиля с двумя знаками после запятой
    /// ## Пример использования:
    /// ```swift
    /// let config = NumberFormatterConfig()
    /// let decimalConfig = customFormatter.decimalStyle(config)
    /// let formatter = decimalConfig.formatter
    /// print(formatter.string(from: 1234.567)) // "1,234.57"
    /// ```
    func decimalStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
        var format = format
        format.numberStyle = .decimal
        format.maximumFractionDigits = 2
        return format
    }

    /// Настраивает форматтер для валютного стиля
    /// ## Пример использования:
    /// ```swift
    /// let config = NumberFormatterConfig()
    /// let currencyConfig = customFormatter.currencyStyle(config)
    /// let formatter = currencyConfig.formatter
    /// print(formatter.string(from: 19.99)) // "$19.99" или "19,99 ₽"
    /// ```
    func currencyStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
        var format = format
        format.numberStyle = .currency
        format.maximumFractionDigits = 2
        return format
    }

    /// Настраивает форматтер для отображения целых чисел (без дробной части)
    /// ## Пример использования:
    /// ```swift
    /// let config = NumberFormatterConfig()
    /// let wholeConfig = customFormatter.wholeStyle(config)
    /// let formatter = wholeConfig.formatter
    /// print(formatter.string(from: 1234.567)) // "1,235"
    /// ```
    func wholeStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig{
        var format = format
        format.maximumFractionDigits = 0
        return format
    }

    func inoutDecimalStyle(_ format: inout NumberFormatterConfig) {
        format.numberStyle = .decimal
    }

    func inoutCurrencyStyle(_ format: inout NumberFormatterConfig) {
        format.numberStyle = .currency
    }

    func inoutWholeStyle(_ format: inout NumberFormatterConfig) {
        format.maximumFractionDigits = 0
    }
}
