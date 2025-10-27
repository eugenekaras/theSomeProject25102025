import Foundation

protocol BookmarksViewModelDelegate: AnyObject {
    func didUpdateBookmarks()
    func didReceiveError(_ message: String)
}

class BookmarksViewModel {
    
    // MARK: - Dependencies
    private let apiService: APIServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    
    // MARK: - Delegate
    weak var delegate: BookmarksViewModelDelegate?
    
    private(set) var bookmarkedUsers: [User] = []
    
    // MARK: - Computed Properties
    
    /// Check if bookmarks list is empty
    var isEmpty: Bool {
        return bookmarkedUsers.isEmpty
    }
    
    /// Get number of bookmarked users
    var bookmarkCount: Int {
        return bookmarkedUsers.count
    }
    
    /// Check if clear all button should be enabled
    var canClearAll: Bool {
        return !isEmpty
    }
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol, bookmarkService: BookmarkServiceProtocol) {
        self.apiService = apiService
        self.bookmarkService = bookmarkService
        
        loadBookmarks()
    }
    
    // MARK: - Public Methods
    
    /// Load bookmarks from storage
    func loadBookmarks() {
        bookmarkedUsers = bookmarkService.bookmarkedUsers
        delegate?.didUpdateBookmarks()
    }
    
    /// Get user at specific index
    func user(at index: Int) -> User? {
        guard index >= 0 && index < bookmarkedUsers.count else { return nil }
        return bookmarkedUsers[index]
    }
    
    /// Get user  presentation model at specific index
    func userCellViewModel(at index: Int) -> UserCellViewModel? {
        let dataSource = bookmarkedUsers
        guard index >= 0 && index < dataSource.count else { return nil }
        
        let user = dataSource[index]
        let userCellViewModel = UserCellViewModel(
            user: user,
            isBookmarked: bookmarkService.isBookmarked(user.uniqueID)
        )
        return userCellViewModel
    }
    
    /// Get index of user at uniqueID
    func indexOfUser(withID id: String) -> Int?  {
        bookmarkedUsers.firstIndex { $0.uniqueID == id }
    }
    
    /// Remove bookmark at specific index
    func removeBookmark(at index: Int) {
        guard let user = user(at: index) else { return }
        bookmarkService.removeBookmark(user)
        // Note: bookmarks will be updated automatically via notification
    }
    
    /// Toggle bookmark for user at index
    func toggleBookmark(at index: Int) {
        guard let user = user(at: index) else { return }
        bookmarkService.toggleBookmark(user)
    }
    
    /// Check if user at index is bookmarked (should always be true in this context)
    func isBookmarked(at index: Int) -> Bool {
        guard let user = user(at: index) else { return false }
        return bookmarkService.isBookmarked(user.uniqueID)
    }
    
    /// Clear all bookmarks
    func clearAllBookmarks() {
        bookmarkService.clearAllBookmarks()
        // Note: bookmarks will be updated automatically via notification
    }
    
    /// Get confirmation message for removing specific bookmark
    func getRemoveConfirmationMessage(at index: Int) -> String {
        guard let user = user(at: index) else { return "Remove bookmark?" }
        return "Remove \(user.fullName) from bookmarks?"
    }
    
    /// Get empty state configuration
    func getEmptyStateConfiguration() -> (imageName: String, title: String, subtitle: String) {
        return (
            imageName: "bookmark.slash",
            title: "No Bookmarks Yet",
            subtitle: "Start bookmarking users to see them here"
        )
    }
    
    /// Get user detail  presentation model at specific index
    func viewModelForDetail(at index: Int) -> UserDetailViewModel? {
        guard index < bookmarkedUsers.count else { return nil }
        let user = bookmarkedUsers[index]
        return UserDetailViewModel(user: user)
    }
}
