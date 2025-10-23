import Foundation

/// Группа приоритета для операторов прямого применения.
///
/// Определяет правила ассоциативности для операторов, которые передают значение
/// в функцию или следующий оператор в цепочке.
///
/// - Note: Левая ассоциативность позволяет строить цепочки операторов,
///   где вычисления выполняются слева направо.
///
/// # Example
///
/// ```
/// let result = 5
///     |> { $0 * 2 }
///     |> { $0 + 1 }
///     |> { "Result: \($0)" }
/// // Вычисляется как: ((5 |> { $0 * 2 }) |> { $0 + 1 }) |> { "Result: \($0)" }
/// // result == "Result: 11"
/// ```
precedencegroup Forward {
    associativity: left
    lowerThan: AssignmentPrecedence // Меньше чем =
}

infix operator |>: Forward


/// Оператор применения функции (Function Application Operator)
/// Принимает значение и функцию, применяет функцию к значению и возвращает результат.
/// Это инфиксная версия обычного вызова функции `f(a)`.
/// - Parameters:
///   - a: Входное значение типа `A`
///   - f: Функция, принимающая значение типа `A` и возвращающая значение типа `B`
/// - Returns: Результат применения функции `f` к значению `a` типа `B`
/// - Note: Оператор |> известен как "pipe operator" и используется для создания цепочек вызовов в функциональном стиле
///
/// - Complexity: O(1)
///
/// # Example
///
/// ```
/// let numbers = [1, 2, 3]
/// let doubled = numbers |> { $0.map { $0 * 2 } }
/// // doubled == [2, 4, 6]
/// ```
func |> <A,B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

func |> <A>(a: inout A, f: (inout A) -> Void) -> A {
    f(&a)
    return a
}


/// Группа приоритета для операторов композиции функций.
///
/// Определяет правила ассоциативности и приоритет для операторов, которые
/// комбинируют функции в последовательные преобразования.
///
/// - Note: Левая ассоциативность позволяет строить цепочки композиций,
///   где функции комбинируются слева направо.
/// - Important: Имеет более высокий приоритет чем `Forward`, что обеспечивает
///   правильный порядок вычислений при смешанном использовании операторов.
///
/// # Example
///
/// ```
/// let increment: (Int) -> Int = { $0 + 1 }
/// let double: (Int) -> Int = { $0 * 2 }
/// let square: (Int) -> Int = { $0 * $0 }
///
/// // Композиция вычисляется как: (increment >>> double) >>> square
/// let transform = increment >>> double >>> square
/// let result = transform(3)
/// // result == 64 (сначала 3+1=4, затем 4*2=8, затем 8*8=64)
/// ```
precedencegroup ForwardComposition {
    associativity: left
    higherThan: Forward
}

infix operator >>>: ForwardComposition

/// Композиция двух функций.
///
/// Принимает две функции и возвращает новую функцию, которая является их композицией.
/// Результат вызова первой функции передается в качестве входного значения второй функции.
///
/// - Parameters:
///   - f: Первая функция, принимающая значение типа `A` и возвращающая значение типа `B`.
///   - g: Вторая функция, принимающая значение типа `B` и возвращающая значение типа `C`.
///
/// - Returns: Новая функция, принимающая значение типа `A` и возвращающая значение типа `C`,
///   которая эквивалентна последовательному применению `f` и `g`.
///
/// - Complexity: O(1)
///
/// # Example
///
/// ```
/// let increment: (Int) -> Int = { $0 + 1 }
/// let double: (Int) -> Int = { $0 * 2 }
/// let incrementAndDouble = increment >>> double
///
/// let result = incrementAndDouble(5)
/// // result == 12 (сначала 5 + 1 = 6, затем 6 * 2 = 12)
/// ```
///
/// # Mathematical Representation
///
/// Если `f: A → B` и `g: B → C`, то `f >>> g: A → C` где `(f >>> g)(x) = g(f(x))`
func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

/// Преобразует функцию вида `(A) -> A` в функцию с inout-параметром `(inout A) -> Void`
/// ## Пример использования:
/// ```swift
/// func increment(_ x: Int) -> Int { x + 1 }
/// let inoutIncrement = toInout(increment)
///
/// var number = 5
/// inoutIncrement(&number) // number становится 6
/// ```
func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    { $0 = f($0) }
}

/// Преобразует функцию с inout-параметром `(inout A) -> Void` в чистую функцию `(A) -> A`
/// ## Пример использования:
/// ```swift
/// func appendExclamation(_ str: inout String) { str += "!" }
/// let pureAppend = fromInout(appendExclamation)
///
/// let result = pureAppend("Hello") // "Hello!"
/// ```
func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var a = a
        f(&a)
        return a
    }
}


precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: Forward
}

infix operator <>: SingleTypeComposition

/// Объединяет две функции с одинаковыми типами в одну композицию
///
/// - Parameters:
///   - f: Первая функция в цепочке композиции
///   - g: Вторая функция в цепочке композиции
/// - Returns: Новая функция, представляющая последовательное применение f и затем g
///
/// ## Пример использования:
/// ```swift
/// func increment(_ x: Int) -> Int { x + 1 }
/// func double(_ x: Int) -> Int { x * 2 }
///
/// let incrementThenDouble = increment <> double
/// let result = incrementThenDouble(5) // (5 + 1) * 2 = 12
/// ```
func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
    return f >>> g
}


/// Объединяет две функции с inout-параметрами в одну композицию
///
/// Оператор применяет функции последовательно к одному и тому же изменяемому значению.
/// Это полезно для создания цепочек модификаторов, которые последовательно изменяют состояние.
///
/// - Parameters:
///   - f: Первая функция, применяемая к значению
///   - g: Вторая функция, применяемая к значению после первой
/// - Returns: Новая функция, которая применяет обе функции последовательно
///
/// ## Пример использования:
/// ```swift
/// func increment(_ x: inout Int) { x += 1 }
/// func double(_ x: inout Int) { x *= 2 }
///
/// let incrementThenDouble = increment <> double
/// var number = 5
/// incrementThenDouble(&number)
/// // number становится: (5 + 1) * 2 = 12
/// ```
///
/// ## Примечание:
/// Обе функции работают с одним и тем же экземпляром значения,
/// модифицируя его последовательно.
func <> <A>(
    f: @escaping (inout A) -> Void,
    g: @escaping (inout A) -> Void
) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}
