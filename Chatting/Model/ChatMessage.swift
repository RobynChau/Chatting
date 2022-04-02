//
//  ChatMessage.swift
//  Chatting
//
//  Created by Robyn Chau on 31/03/2022.
//

import Foundation


struct ChatMessage: Identifiable{
    var id: String { documentID }

    let documentID: String
    let fromID, toID, text: String

    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.fromID = data["fromID"] as? String ?? ""
        self.toID  = data["toID"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }

    var isFromID: Bool {
        fromID == FirebaseManager.shared.auth.currentUser?.uid
    }
}
