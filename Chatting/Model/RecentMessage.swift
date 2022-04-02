//
//  RecentMessage.swift
//  Chatting
//
//  Created by Robyn Chau on 03/04/2022.
//

import SwiftUI
import FirebaseFirestore

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

struct RecentMessage: Identifiable {
    var id: String { documentId }

    let documentId: String
    let text, email: String
    let fromID, toID: String
    let profileImageURL: String
    let timestamp: Date

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromID = data["fromID"] as? String ?? ""
        self.toID = data["toID"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }

    var username: String {
        email.components(separatedBy: "@").first ?? email
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
