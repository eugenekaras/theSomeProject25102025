//
//  DIContainer.swift
//  Challenge
//
//  Created by Yauheni Karas on 27/10/2025.
//

import Foundation

// MARK: - DIContainer
final class DIContainer {
    
    // MARK: - Dependencies
    let apiService: APIServiceProtocol
    let bookmarkService: BookmarkServiceProtocol
    let imageLoadingService: ImageLoadingServiceProtocol

    // MARK: - Initialization
    init(
        apiService: APIServiceProtocol = APIService(),
        bookmarkService: BookmarkServiceProtocol = BookmarkManager(),
        imageLoadingService: ImageLoadingServiceProtocol = ImageLoadingService()
    ) {
        self.apiService = apiService
        self.bookmarkService = bookmarkService
        self.imageLoadingService = imageLoadingService
    }
}
