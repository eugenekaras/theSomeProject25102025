import UIKit

protocol UserDetailCoordinatorDelegate: AnyObject {
    func userDetailCoordinatorDidFinish(_ coordinator: UserDetailCoordinator)
}

class UserDetailCoordinator: Coordinator {
    // MARK: - Dependencies
    private let diContainer: DIContainer
    
    weak var delegate: UserDetailCoordinatorDelegate?
    var navigationController: UINavigationController
    
    private let user: User
    
    init(
        navigationController: UINavigationController,
        diContainer: DIContainer,
        user: User
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.user = user
    }
    
    deinit {
        print("\(Self.self) deinitialized")
    }
    
    func start() {
        showUserDetail()
    }
    
    private func showUserDetail() {
        let viewModel = UserDetailViewModel(
            bookmarkService: diContainer.bookmarkService,
            imageLoadingService: diContainer.imageLoadingService,
            user: user,
        )
        let userDetailVC = UserDetailViewController(with: viewModel)
        userDetailVC.coordinator = self
        navigationController.pushViewController(userDetailVC, animated: true)
    }
    
    func didFinishUserDetail() {
        delegate?.userDetailCoordinatorDidFinish(self)
    }
    
    func presentShareActivity(with items: [Any], from sourceView: UIView?) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            if let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            } else {
                popover.sourceView = navigationController.view
                popover.sourceRect = CGRect(
                    x: navigationController.view.bounds.midX,
                    y: navigationController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
        }
        
        navigationController.present(activityVC, animated: true)
    }
}
