//
//  MainMessagesView.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessagesView: View {
    @State var showingLogOutOptions = false
    @State private var showingNewMessageScreen = false
    @State private var showingChatLog = false
    @State private var chatUser: User?
    @ObservedObject var viewModel = MainMessagesViewModel()

    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @State private var navigatingToChatLogView = false

    var body: some View {
        NavigationView {
            VStack {
                customNavigationBar
                messagesView
                NavigationLink("", isActive: $navigatingToChatLogView) {
                    ChatLogView(viewModel: chatLogViewModel)
                }
                .navigationViewStyle(.stack)
                newMessageButton
                    .offset(CGSize(width: 0, height: 10))
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                viewModel.isUserCurrentlyLoggedOut = false
                viewModel.fetchCurrentUser()
            })
        }
        .fullScreenCover(isPresented: $showingNewMessageScreen) {
            CreateNewMessageView(didSelectUser: { user in
                chatUser = user
                showingChatLog.toggle()
            })
        }
    }

    private var customNavigationBar: some View {
        HStack(spacing: 16) {
            if (viewModel.user?.profileImageURL != nil) {
            WebImage(url: URL(string: viewModel.user?.profileImageURL ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.label), lineWidth: 1)
                )

            } else {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.user?.filteredEmail ?? "")")
                    .font(.system(size: 24, weight: .bold))

                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }

            }

            Spacer()
            Button {
                showingLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .confirmationDialog("Settings", isPresented: $showingLogOutOptions, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                viewModel.handleSignOut()
            }
        }
    }

    private var messagesView: some View {
        ScrollView {
            ForEach(viewModel.recentMessages) { message in
                Button {
                    let uid = FirebaseManager.shared.auth.currentUser?.uid == message.fromID ? message.toID : message.fromID
                    self.chatUser = .init(data: ["email": message.email, "profileImageURL": message.profileImageURL, "uid": uid])
                    self.chatLogViewModel.chatUser = self.chatUser
                    self.chatLogViewModel.fetchMessages()
                    self.navigatingToChatLogView.toggle()
                } label: {
                    VStack(alignment: .leading) {
                        HStack(spacing: 16) {
                            if (message.profileImageURL != nil) {
                            WebImage(url: URL(string: message.profileImageURL))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(.label), lineWidth: 1)
                                )

                            } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 34, weight: .heavy))
                            }
                            VStack(alignment: .leading) {
                                Text(message.username)
                                    .font(.headline)
                                Text(message.text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(message.timeAgo)
                                .font(.subheadline)
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }.padding(.horizontal)
                }
                .foregroundColor(.primary)
            }.padding(.bottom, 50)
        }
    }

    private var newMessageButton: some View {
        Button {
            showingNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("New Message")
                    .font(.headline.bold())
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
