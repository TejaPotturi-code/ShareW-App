//
//  GroupFriendsView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/4/24.
//

import SwiftUI

struct GroupFriendsView: View {
    
    
    
    @State var friends: [User] = []
    
    @Binding var members: [User]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Text("Total members added: \(members.count)")
            Section("Added to Group") {
                ForEach(members, id: \.uid) { friend in
                    VStack {
                        HStack {
                            Text(friend.email)
                                .font(.title3)
                            Spacer()
                            AsyncImage(url: URL(string: friend.imageURL.description), transaction: .init(animation: .spring())) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 20,height: 20)
                                case .failure(let error):
                                    Text("Image not Found! \(error.localizedDescription)")
                                @unknown default:
                                    Text("User Image not Found!")
                                }
                            }
                        }
                    }
                    .shadow(color: .green, radius: 10)
                    .onTapGesture {
                        friends.append(friend)
                        members.removeAll(where: { $0.email == friend.email })
                    }
                }
            }
            
            Section("Add to Group") {
                ForEach(friends, id: \.uid) { friend in
                    VStack {
                        HStack {
                            Text(friend.email)
                                .font(.title3)
                            Spacer()
                            AsyncImage(url: URL(string: friend.imageURL.description), transaction: .init(animation: .spring())) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 20,height: 20)
                                case .failure(let error):
                                    Text("Image not Found! \(error.localizedDescription)")
                                @unknown default:
                                    Text("User Image not Found!")
                                }
                            }
                        }
                    }
                    .shadow(radius: 10)
                    .onTapGesture {
                        members.append(friend)
                        friends.removeAll(where: { $0.email == friend.email })
                    }
                }
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
            }
        })
        .onAppear(perform: {
            getUserDetails()
        })
    }
    private func getUserDetails() {
        
        let uid : String = UserDefaults.standard.object(forKey: "uid") as! String
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
                        
                        self.friends = self.friends.filter({
                            for obj in members {
                                if obj.email == $0.email {
                                    return false
                                }
                            }
                            return true
                        })
                        
                    }
                    
                }
            }
    }
}

#Preview {
    GroupFriendsView(members: .constant([]))
}
