//
//  MainMessagesViewModel.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import Foundation
import FirebaseFirestore

class MainMessagesViewModel: ObservableObject {
    @Published var user: User?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var recentMessages = [RecentMessage]()

    private var firestoreListener: ListenerRegistration?


    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }

    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { [self] snapshot, error in
            if let error = error {
                fatalError("Failed to fetch current user: \(error.localizedDescription)")
            }

            guard let data = snapshot?.data() else { return }

            user = User.init(data: data)
        }
    }

    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        firestoreListener?.remove()
        self.recentMessages.removeAll()

        firestoreListener = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").order(by: "timestamp").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    fatalError("\(error.localizedDescription)")
                }

                querySnapshot?.documentChanges.forEach({ change in
                    let docID = change.document.documentID

                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == docID
                    }) {
                        self.recentMessages.remove(at: index)
                    }

                    self.recentMessages.insert(.init(documentId: docID, data: change.document.data()), at: 0)
                })
            }
    }


    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
