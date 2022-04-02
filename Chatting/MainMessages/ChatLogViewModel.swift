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

    let chatUser: User?

    @Published var count = 0

    init(chatUser: User?) {
        self.chatUser = chatUser
        fetchMessages()
    }


    func handleSendText() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toID = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection("messages").document(fromID).collection(toID).document()

        let messageData = ["fromID": fromID, "toID": toID, "text": text, "timestamp": Timestamp()] as [String : Any]

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

        self.text = ""
        self.count += 1

    }

    private func fetchMessages() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toID = chatUser?.uid else { return }

        FirebaseManager.shared.firestore.collection("messages").document(fromID).collection(toID).order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }

            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.chatMessages.append(ChatMessage(data: data))
                }
            })

            DispatchQueue.main.async {
                self.count += 1
            }
        }
    }
}
