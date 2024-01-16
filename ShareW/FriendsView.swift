//
//  FriendsView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/2/24.
//

import SwiftUI

class User: Identifiable, ObservableObject {
    var id : String {
        self.uid
    }
    var uid: String
    var imageURL: String
    @Published var email: String
    
    init(uid: String, imageURL: String, email: String) {
        self.uid = uid
        self.imageURL = imageURL
        self.email = email
    }
}

struct FriendsView: View {
    
    @State var email: String = "das"
    @State var imageURL: String = ""
    @State var showSheet: Bool = false
    @State var friends: [User] = []
    
    init() {
        
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(friends, id: \.uid) { friend in
                    VStack {
                        HStack {
                            Text(friend.email)
                                .font(.title3)
                                .lineLimit(1)
                            Spacer()
                            AsyncImage(url: URL(string: friend.imageURL.description), transaction: .init(animation: .spring())) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 50,height: 50)
                                        .clipShape(Circle())
                                case .failure(let error):
                                    Text("Image not Found! \(error.localizedDescription)")
                                @unknown default:
                                    Text("User Image not Found!")
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    
                })
            }
            .navigationTitle("Friends")
            .scrollIndicators(.hidden)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button(action: {
                        showSheet.toggle()
                    }, label: {
                        Image(systemName: "person.fill.badge.plus")
                    })
                }
            })
            .sheet(isPresented: $showSheet, content: {
                AddFriendView(friends: $friends)
            })
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: {
            getUserDetails()
        })
    }
    private func getUserDetails() {
        
        let uid : String = UserDefaults.standard.object(forKey: "uid") as! String
        let email : String = UserDefaults.standard.object(forKey: "email") as! String
        let imageURL : String = UserDefaults.standard.object(forKey: "imageURL") as! String
                self.email = email
                self.imageURL = imageURL
                
        FirebaseManager.shared.firestore.collection("friends")
            .document(uid).getDocument { snapshot, error in
                if error != nil {
                    print("Testing error in getting data")
                    return
                }
                if let data: [String: Any] = snapshot?.data() {
                    
                    self.friends = []
                    
                    for (_, value ) in data {
                        
                        guard let dic = value as? [AnyHashable : String] else {
                            print("Cannot convert")
                            return
                        }
                        self.friends.append(User(uid: dic["uid"] ?? "", imageURL: dic["imageURL"] ?? "", email: dic["email"] ?? ""))
                        print("testing values")
                        print("email, \(dic["email"] ?? "")")
                        print("ImageURL, \(dic["imageURL"] ?? "")")
                        print("UID, \(dic["uid"] ?? "")")
                    }
                    
                }
            }
    }
}


#Preview {
    FriendsView()
}
