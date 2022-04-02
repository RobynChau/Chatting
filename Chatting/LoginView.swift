//
//  ContentView.swift
//  Chatting
//
//  Created by Robyn Chau on 29/03/2022.
//

import SwiftUI

struct LoginView: View {
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    let didCompleteLoginProcess: () -> ()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker(selection: $isLoginMode, label: Text("Login Picker")) {
                    Text("Login")
                        .tag(true)
                    Text("Create Account")
                        .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if !isLoginMode {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Group {
                                if let inputImage = inputImage {
                                    Image(uiImage: inputImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 116, height: 116)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle")
                                        .frame(width: 116, height: 116)
                                        .font(.system(size: 116))
                                }
                            }
                                .labelStyle(.iconOnly)
                                .padding(.bottom)
                        } 
                    }
                    Section {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(.gray.opacity(0.15))
                    .cornerRadius(5.0)
                    .padding([.horizontal, .bottom], 12)

                    Button {
                        handleAction()
                    } label: {
                        Text(isLoginMode ? "Login" : "Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 180, minHeight: 40)
                            .background(Color.blue)
                    }
                    .clipShape(Capsule())
                }
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
            }
            .fullScreenCover(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
    }

    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewUser()
        }
    }

    private func createNewUser() {
        if inputImage == nil {
            alertTitle = "Missing avatar image."
            alertMessage = "Please choose an image for your avatar."
            showingAlert.toggle()
            return
        }

        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertTitle = "Failed to create account."
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }

            persistImageToStorage()
        }
    }

    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                let ref = FirebaseManager.shared.storage.reference(withPath: uid)
                guard let imageData = inputImage?.jpegData(compressionQuality: 0.5) else { return }
                ref.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        alertTitle = "Failed to upload image."
                        alertMessage = error.localizedDescription
                        showingAlert.toggle()
                        return
                    }

                    ref.downloadURL { url, error in
                        if let error = error {
                            alertTitle = "Failed to retrieve image."
                            alertMessage = error.localizedDescription
                            showingAlert.toggle()
                            return
                        }

                        guard let url = url else {
                            return
                        }
                        storeUserInformation(imageProfileURL: url)
                    }
                }
    }

    private func storeUserInformation(imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": email, "uid": uid, "profileImageURL": imageProfileURL.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    alertTitle = "Failed to store user's information."
                    alertMessage = error.localizedDescription
                    showingAlert.toggle()
                    return
                }
            }
    }

    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertTitle = "Failed to log in."
                alertMessage = error.localizedDescription
                showingAlert.toggle()
                return
            }
            self.didCompleteLoginProcess()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: { })
    }
}
