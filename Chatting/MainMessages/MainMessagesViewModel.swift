//
//  MainMessagesViewModel.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import Foundation

class MainMessagesViewModel: ObservableObject {
    @Published var user: User?
    @Published var isUserCurrentlyLoggedOut = false

    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
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

    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
