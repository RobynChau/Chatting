//
//  CreateNewMessageView.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel = CreateNewMessageViewModel()

    let didSelectUser: (User) -> ()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    Button {
                        didSelectUser(user)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageURL))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(.label), lineWidth: 2)
                                )
                            Text(user.email)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                Button("Cancel") {
                    dismiss()
                }
            }
        }

    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
        //CreateNewMessageView()
    }
}
