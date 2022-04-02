//
//  User.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import Foundation

struct User: Identifiable {
    var id: String { uid }
    let uid, email, profileImageURL: String

    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
    }

    static var example: User {
        .init(data: ["uid": "cN6VwA1aLMaQZIUDZ9kHI7yHdDy1", "email": "chphat@gmail.com" , "profileImageURL": "https://firebasestorage.googleapis.com:443/v0/b/chatting-swiftui.appspot.com/o/cN6VwA1aLMaQZIUDZ9kHI7yHdDy1?alt=media&token=e5c2e277-2f42-4c57-a3b4-bd5de1ad3d94"])
    }

    var filteredEmail: String {
        email.replacingOccurrences(of: "@gmail.com", with: "")
    }
}
