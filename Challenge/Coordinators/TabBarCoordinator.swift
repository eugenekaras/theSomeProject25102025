import UIKit

class TabBarCoordinator: NSObject, Coordinator {
    // MARK: - Dependencies
    private let diContainer: DIContainer

    // MARK: - UI
    private(set) var tabBarController: MainTabBarController
    
    // MARK: - Coordinators
    private var usersListCoordinator: UsersListCoordinator?
    private var bookmarksCoordinator: BookmarksCoordinator?
    
    init(
        diContainer: DIContainer,
        tabBarController: MainTabBarController
    ) {
        self.diContainer = diContainer
        self.tabBarController = tabBarController
        super.init()
    }
    
    func start() {
        setupCoordinators()
        tabBarController.setupBookmarkBadgeObserver()
    }
    
    private func setupCoordinators() {
        // Users List Coordinator
        let usersListNavController = UINavigationController()
        usersListCoordinator = UsersListCoordinator(
            navigationController: usersListNavController,
            diContainer: diContainer
        )

        usersListNavController.tabBarItem = UsersListCoordinator.makeTabBarItem()
        
        // Bookmarks Coordinator
        let bookmarksNavController = UINavigationController()
        bookmarksCoordinator = BookmarksCoordinator(
            navigationController: bookmarksNavController,
            diContainer: diContainer
        )
        
        bookmarksNavController.tabBarItem = BookmarksCoordinator.makeTabBarItem()
        
        // Set up tab bar view controllers
        tabBarController.viewControllers = [usersListNavController, bookmarksNavController]
        
        // Start child coordinators
        usersListCoordinator?.start()
        bookmarksCoordinator?.start()
    }
}

// MARK: - TabBarItem Factory
extension UsersListCoordinator {
    static func makeTabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: "Users",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
    }
}

extension BookmarksCoordinator {
    static func makeTabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: "Bookmarks",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
    }
}
