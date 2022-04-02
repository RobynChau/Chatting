//
//  CreateNewMessageViewModel.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import Foundation

class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [User]()

    init() {
        fetchAllUsers()
    }

    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            if let error = error {
                fatalError("Failed to fetch users: \(error.localizedDescription)")
            }

            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })

            self.users.sort {$0.email > $1.email}
        }
    }
}
