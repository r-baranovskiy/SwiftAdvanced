import Foundation

protocol IServiceLocator
{
    func register<T>(service: T)
    func resolve<T>() -> T
    func clear()
    func removeService<T>(_ service: T)
}

final class ServiceLocator
{
    static let shared = ServiceLocator()

    private(set) lazy var services: Dictionary<String, Any> = [:]
}

// MARK: - IServiceLocator

extension ServiceLocator: IServiceLocator
{
    func register<T>(service: T) {
        let key = typeName(some: T.self)
        self.services[key] = service
    }
    
    func resolve<T>() -> T {
        let key = typeName(some: T.self)
        return services[key] as! T
    }

    func clear() {
        services.removeAll()
    }

    func removeService<T>(_ service: T) {
        let key = typeName(some: T.self)
        services.removeValue(forKey: key)
    }
}

// MARK: - Private

private extension ServiceLocator
{
    func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}
