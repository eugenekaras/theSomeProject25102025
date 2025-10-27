import UIKit

class AppCoordinator: Coordinator {
    var tabBarCoordinator: TabBarCoordinator!
    
    private let window: UIWindow
    private let diContainer: DIContainer
    
    init(window: UIWindow) {
        self.window = window
        self.diContainer = DIContainer()
    }
    
    func start() {
        tabBarCoordinator = TabBarCoordinator(diContainer: diContainer)
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabBarCoordinator.start()
    }
}
