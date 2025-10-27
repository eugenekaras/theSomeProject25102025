import UIKit

class BookmarksCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var userDetailCoordinator: UserDetailCoordinator?
    
    // MARK: - Dependencies
    private let diContainer: DIContainer
    
    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        showBookmarks()
    }
    
    private func showBookmarks() {
        let bookmarksViewModel = BookmarksViewModel(
              apiService: diContainer.apiService,
              bookmarkService: diContainer.bookmarkService,
              imageLoadingService: diContainer.imageLoadingService
          )
        
        let bookmarksVC = BookmarksViewController(
            viewModel: bookmarksViewModel,
            imageService: diContainer.imageLoadingService
        )
        bookmarksVC.coordinator = self
        navigationController.pushViewController(bookmarksVC, animated: false)
    }
    
    func showUserDetail(with viewModel: UserDetailViewModel) {
        userDetailCoordinator = UserDetailCoordinator(
            navigationController: navigationController,
            viewModel: viewModel
        )
        userDetailCoordinator?.delegate = self
        userDetailCoordinator?.start()
    }
}

// MARK: - UserDetailCoordinatorDelegate
extension BookmarksCoordinator: UserDetailCoordinatorDelegate {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator) {
        userDetailCoordinator = nil
    }
}
