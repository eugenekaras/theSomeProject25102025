import UIKit

class UsersListCoordinator: Coordinator {
    
    // MARK: - Dependencies
    private let diContainer: DIContainer
    
    // MARK: - Navigation
    var navigationController: UINavigationController
    
    // MARK: - Coordinators
    private var userDetailCoordinator: UserDetailCoordinator?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        showUsersList()
    }
    
    private func showUsersList() {
        let usersListViewModel = UsersListViewModel(
              apiService: diContainer.apiService,
              bookmarkService: diContainer.bookmarkService,
              imageLoadingService: diContainer.imageLoadingService
          )
        
        let usersListVC = UsersListViewController(
            viewModel: usersListViewModel,
            imageService: diContainer.imageLoadingService
        )
        usersListVC.coordinator = self
        navigationController.pushViewController(usersListVC, animated: false)
    }
    
    func showUserDetail(for user: User) {
        userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            diContainer: diContainer,
            user: user
        )
        userDetailCoordinator?.delegate = self
        userDetailCoordinator?.start()
    }
}

// MARK: - UserDetailCoordinatorDelegate
extension UsersListCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}
