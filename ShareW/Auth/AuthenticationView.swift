//
//  AuthenticationView.swift
//  ShareW
//
//  Created by Teja Potturi on 12/31/23.
//

import SwiftUI
import Firebase
import Foundation

struct AuthenticationView: View {
    
    @State private var type: Bool = true
    @State var email: String = ""
    @State var password: String = ""
    @State var errormessage: String = ""
    @State var imagePerson : UIImage?
    @State var isLogin: Bool = false
    @State var imageShow: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if !type {
                    Button {
                        imageShow.toggle()
                    } label: {
                        if let image = self.imagePerson {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 130,height: 130)
                                .clipShape(Circle())
                                .padding(.bottom)
                        } else {
                            Image(systemName: type ? "" : "person.circle.fill")
                                .resizable()
                                .frame(width: 130,height: 130)
                                .padding(.bottom)
                                .foregroundStyle(Color(.label))
                        }
                    }
                }
                if validateEmail() {
                    HStack {
                        Text("Enter a valid Email!")
                            .font(.caption)
                            .foregroundStyle(Color.red)
                        Spacer()
                    }
                }
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                    .padding(.bottom, 20)
                    .textInputAutocapitalization(.never)
                
                if validatePassword() {
                    HStack {
                        Text("Enter a valid Password!")
                            .font(.caption)
                            .foregroundStyle(Color.red)
                        Spacer()
                    }
                }
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                    .padding(.bottom, 20)
                    .textInputAutocapitalization(.never)
                
                
                Button {
                    handleSignIn()
                } label: {
                    Text(type ? "Login" : "SignUp")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background((email.isEmpty || validateEmail() || validatePassword() || password.isEmpty) ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || validateEmail() || validatePassword() || password.isEmpty)
                
                if self.errormessage.count > 0 {
                    Text(self.errormessage)
                        .font(.callout)
                        .foregroundStyle(Color.red)
                }
                
                Button(action: {
                    type.toggle()
                    self.password = ""
                    self.errormessage = ""
                }) {
                    HStack {
                        Spacer()
                        Text(type ? "Create Account" : "Already have account")
                    }
                    .padding(.top)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(type ? "Login" : "SignUp")
            .navigationDestination(isPresented: $isLogin) {
                    TabBarView(isLogin: $isLogin)
                        .navigationBarBackButtonHidden()
            }
            .sheet(isPresented: $imageShow, content: {
                ImagePicker(image: $imagePerson)
            })
        }
    }
    
    private func validateEmail() -> Bool {
        if  self.email.count > 0 &&  (!self.email.contains("@gmail.com") || self.email.count <= 10) {
            return true
        }
        return false
    }
    
    private func validatePassword() -> Bool {
        if  self.password.count > 0 &&  self.password.count <= 5 {
            return true
        }
        return false
    }
    
    private func handleSignIn() {
        if type {
            loginAccount()
        } else {
            CreateAccount()
        }
    }
    
    private func loginAccount() {
        print("Here came")
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            print("Here came1")
            
            if let err = error {
                print("Failed to login.",err)
                self.errormessage = "Login Failed!"
                return
            }
            self.errormessage = "Login Succesfull."
            
            UserDefaults.standard.set(email, forKey: "email")
            
            isLogin.toggle()
        }
        
    }
    
    private func CreateAccount() {
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Failed to create User with error,",err)
                self.errormessage = "Failed to create User with error!"
                return
            }
            
            print("Account created: \(result?.user.uid ?? "")")
            self.errormessage = "Account Created \(result?.user.uid ?? "")"
            
            password = ""
            type.toggle()
            
            saveImagePerson()
        }
    }
    
    private func saveImagePerson() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.imagePerson?.jpegData(compressionQuality: 0.5)
        else {
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let err = error {
                print(err)
                //self.errormessage = "Failed to upload the image \(err)"
                return
            }
            
            ref.downloadURL { url, error in
                if let err = error {
                    print(err)
                    //self.errormessage = "Failed to download the image \(err)"
                    return
                }
                //self.errormessage = "Sucess downloaded the data \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                storeUserInformation(url: url, uid: uid)
                
            }
        }
    }
    
    private func storeUserInformation(url: URL, uid: String) {
        let userData = [ "email": self.email ,
                         "uid":uid,
                         "imageURL": url.absoluteString
        ]
        
        let friends = [
            "\(uid)" : ["email": self.email ,
                "uid":uid,
                "imageURL": url.absoluteString]
        ]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let err = error {
                    print("Error in saving data \(err)")
                    //errormessage = "Failed to save user data \(err)"
                    return
                }
                print("Success to create users data")
                //errormessage = "Success to create users data"
                FirebaseManager.shared.firestore.collection("friends")
                    .document(uid).setData(friends) { error in
                        
                        if let err = error {
                            print("Error in adding friends field \(err)")
                            return
                        }
                        
                    }
                print("sucess in adding users fields")
            }
    }
    
}

#Preview {
    AuthenticationView()
}
