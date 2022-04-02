//
//  ChatLogView.swift
//  Chatting
//
//  Created by Robyn Chau on 30/03/2022.
//

import SwiftUI

struct ChatLogView: View {
    @ObservedObject var viewModel: ChatLogViewModel

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        VStack {
            messagesView
            Spacer()
            chatBottomBar
                .padding(.horizontal)
                .background(Color.white.ignoresSafeArea())
        }
        .navigationTitle(viewModel.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
    }

    static let emptyScrollToString = "Empty"

    var messagesView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(viewModel.chatMessages) { message in
                            MessageView(message: message)
                        }

                        HStack{ Spacer() }
                        .id(Self.emptyScrollToString)
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }

                }
            }
        }
    }

    var chatBottomBar: some View {
        HStack {
            Button {
                showingImagePicker = true
            } label: {
                Label("Image Picker", systemImage: "photo.on.rectangle.angled")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }

            ZStack(alignment: .leading) {
                DescriptionPlaceholder()
                TextEditor(text: $viewModel.text)
                    .opacity(viewModel.text.isEmpty ? 0.5 : 1)
                    .font(.system(size: 20))
            }
            .frame(height: 40)
            .padding()
            .cornerRadius(5.0)

            Button{
                viewModel.handleSendText()
            } label: {
                Label("Send Button", systemImage: "paperplane.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
        }
    }
    private struct DescriptionPlaceholder: View {
        var body: some View {
            HStack {
                Text("Description")
                    .foregroundColor(Color(.gray))
                    .font(.system(size: 20))

                Spacer()
            }
            .padding(.leading, 3)
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(viewModel: ChatLogViewModel(chatUser: nil))
    }
}
