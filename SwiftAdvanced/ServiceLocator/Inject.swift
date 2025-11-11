import Foundation

@propertyWrapper
struct Inject<T>
{
    private let serviceLocator: IServiceLocator
    
    var wrappedValue: T {
        get {
            serviceLocator.resolve()
        }
    }
    
    init(serviceLocator: IServiceLocator = ServiceLocator.shared) {
        self.serviceLocator = serviceLocator
    }
}
