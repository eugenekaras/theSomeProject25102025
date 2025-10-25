//
//  UserCellViewModel.swift
//  Challenge
//
//  Created by Yauheni Karas on 25/10/2025.
//

import Foundation

struct UserCellViewModel {
    let fullName: String
    let email: String
    let locationText: String
    let avatarURL: String?
    let initials: String
    let isBookmarked: Bool
    let userID: String
    
    init(user: User, isBookmarked: Bool) {
        self.fullName = "\(user.name.first) \(user.name.last)"
        self.email = user.email
        self.locationText = "\(user.location.city), \(user.location.country)"
        self.avatarURL = user.picture.thumbnail
        self.initials = "\(user.name.first.first.map(String.init) ?? "")\(user.name.last.first.map(String.init) ?? "")"
        self.isBookmarked = isBookmarked
        self.userID = user.uniqueID
    }
}
