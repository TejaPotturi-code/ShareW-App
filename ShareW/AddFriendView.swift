//
//  AddFriendView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/3/24.
//

import SwiftUI



struct AddFriendView: View {
    
    @Binding var friends: [User]
    @State var search: String = ""
    @State var showProgessiBar : Bool = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userFriend : User = User(uid: "", imageURL: "", email: "")
    
    var body: some View {
        NavigationStack {
            VStack {
                if search.isEmpty {
                    Text("Search by complete Email to add your friend!")
                        .font(.title3)
                        .padding()
                    Spacer()
                }
                
                if showProgessiBar {
                    ProgressView()
                }
                
                List {
                    
                    if userFriend.email.count > 0 {
                        
                        VStack {
                            
                            HStack {
                                VStack {
                                    Text("User Email")
                                    Text("\(userFriend.email)")
                                        .font(.title2)
                                }
                                Spacer()
                                imageURLToImage(imageURL: $userFriend.imageURL)
                                    .frame(width: 50,height: 50)
                                    .padding()
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal)
                            
                            if checkAlreadyUser() {
                                Text("Already in Friends List!")
                                    .foregroundStyle(Color.gray)
                            } else {
                                Button(action: {
                                    
                                    addNewUser()
                                    
                                }, label: {
                                    HStack {
                                        Image(systemName: "plus")
                                            .frame(width: 30,height: 30)
                                        Text("Friends List")
                                    }
                                })
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                            }
                        }
                    }
                }
                .searchable(text: $search, isPresented: .constant(true))
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Back")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                })
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                }
            })
            .onChange(of: search) { oldValue, newValue in
                showProgessiBar = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    showProgessiBar = false
                    if search.count > 10 && search.contains("@gmail.com") {
                        getUser()
                    } else {
                        userFriend.uid = ""
                        userFriend.email = ""
                        userFriend.imageURL = ""
                    }
                }
                
            }
        }
    }
    
    private func getUser() {
        
        FirebaseManager.shared.firestore.collection("users").whereField("email", isEqualTo: search.lowercased()).getDocuments { snapshot, error in
            if let err = error {
                print("error in seaching user \(err)")
                
                userFriend.uid = ""
                userFriend.email = ""
                userFriend.imageURL = ""
                
                return
            }
            for document in snapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                userFriend.uid = document["uid"] as! String
                userFriend.email = document["email"] as! String
                userFriend.imageURL = document["imageURL"] as! String
                print("test1 \(userFriend.email)")
            }
        }
    }
    
    private func addNewUser() {
        
        let uid : String = UserDefaults.standard.object(forKey: "uid") as! String
        
        let newfriend = [
            "\(userFriend.uid)" : ["email": userFriend.email ,
                                   "uid": userFriend.uid,
                                   "imageURL": userFriend.imageURL]
        ]
        
        let curruser = friends.first(where: { $0.uid == uid })
        print(curruser ?? "")
        
        let newfriend1 = [
            "\(curruser!.uid)" : ["email": curruser!.email ,
                                 "uid": curruser!.uid,
                                 "imageURL": curruser!.imageURL]
        ]
        
        FirebaseManager.shared.firestore.collection("friends")
            .document(uid).updateData(newfriend) { error in
                if let err = error {
                    print("Error in adding friends field \(err)")
                    return
                }
                print("Sucess in adding new friend")
                friends.append(User(uid: userFriend.uid, imageURL: userFriend.imageURL, email: userFriend.email))
            }
        
        FirebaseManager.shared.firestore.collection("friends")
            .document(userFriend.uid).updateData(newfriend1) { error in
                if let err = error {
                    print("Error in adding friends field \(err)")
                    return
                }
                print("Sucess in adding new friend")
            }
        
        //        FirebaseManager.shared.firestore.collection("friends")
        //            .document(uid).setData(newfriend) { error in
        //                if let err = error {
        //                    print("Error in adding friends field \(err)")
        //                    return
        //                }
        //                print("Sucess in adding new friend")
        //                friends.append(User(uid: userFriend.uid, imageURL: userFriend.imageURL, email: userFriend.email))
        //            }
        
    }
    
    private func checkAlreadyUser() -> Bool {
        for friend in friends {
            
            if friend.email == userFriend.email {
                return true
            }
        }
        return false
    }
}

#Preview {
    AddFriendView(friends: .constant([User(uid: "1wqeq", imageURL: "", email: "sja")]))
}


struct imageURLToImage : View {
    
    @Binding var imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL.description), transaction: .init(animation: .spring())) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
            case .failure(let error):
                Text("Image not Found! \(error.localizedDescription)")
            @unknown default:
                Text("User Image not Found!")
            }
        }
    }
}
