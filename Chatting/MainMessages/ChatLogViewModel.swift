//
//  ChatLogViewModel.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import Foundation
import FirebaseFirestore

class ChatLogViewModel: ObservableObject {
    @Published var text = ""

    @Published var chatMessages = [ChatMessage]()

    var chatUser: User?

    @Published var count = 0

    init(chatUser: User?) {
        self.chatUser = chatUser
        fetchMessages()
    }

    var firestoreListener: ListenerRegistration?

    func handleSendText() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toID = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection("messages").document(fromID).collection(toID).document()

        let messageData = ["fromID": fromID, "toID": toID, "text": text, "timestamp": Date()] as [String : Any]

        document.setData(messageData) { error in
            if let error = error {
                fatalError("Error: \(error)")
            }
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages").document(toID).collection(fromID).document()

        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }

        self.persistRecentMessage()

        self.text = ""
        self.count += 1

    }

    func fetchMessages() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toID = chatUser?.uid else { return }

        firestoreListener?.remove()
        chatMessages.removeAll()

        firestoreListener = FirebaseManager.shared.firestore.collection("messages").document(fromID).collection(toID).order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }

            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.chatMessages.append(.init(documentID: change.document.documentID, data: data))
                }
            })

            DispatchQueue.main.async {
                self.count += 1
            }
        }
    }

    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toID = self.chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").document(toID)

        let data = [
            "timestamp": Timestamp(),
            "text": self.text,
            "fromID": uid,
            "toID": toID,
            "profileImageURL": chatUser.profileImageURL,
            "email": chatUser.email
            ] as [String : Any]

            // you'll need to save another very similar dictionary for the recipient of this message...how?

            document.setData(data) { error in
                if let error = error {
                    fatalError("Failed to save recent message: \(error)")
                }
            }

        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            "timestamp": Timestamp(),
            "text": self.text,
            "fromID": uid,
            "toID": toID,
            "profileImageURL": currentUser.profileImageURL,
            "email": currentUser.email
        ] as [String : Any]

        FirebaseManager.shared.firestore.collection("recent_messages").document(toID).collection("messages").document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
}
