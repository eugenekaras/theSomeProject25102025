import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Dependencies
    private let bookmarkService: BookmarkServiceProtocol
    
    // MARK: - Properties
    private var bookmarkBadgeObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    // MARK: - Initialization
    init(bookmarkService: BookmarkServiceProtocol) {
        self.bookmarkService = bookmarkService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = bookmarkBadgeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    func setupBookmarkBadgeObserver() {
        guard viewControllers != nil else { return }
        
        bookmarkBadgeObserver = NotificationCenter.default.addObserver(
            forName: BookmarkManager.bookmarkDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBookmarkBadge()
        }
        
        updateBookmarkBadge()
    }
    
    private func updateBookmarkBadge() {
        let bookmarkCount = bookmarkService.bookmarkedCount
        let bookmarkTab = viewControllers?[1]
        
        if bookmarkCount > 0 {
            bookmarkTab?.tabBarItem.badgeValue = "\(bookmarkCount)"
        } else {
            bookmarkTab?.tabBarItem.badgeValue = nil
        }
    }
}
