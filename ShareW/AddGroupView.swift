//
//  AddGroupView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/4/24.
//

import SwiftUI

struct AddGroupView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var title: String = ""
    @State var type: String = ""
    @State var show: Bool = false
    @State var members: [User] = []
    
    
    let colums: [GridItem] = [
        GridItem(.adaptive(minimum: 40, maximum: 50),spacing: 10, alignment: nil),
    ]
    
    var body: some View {
        ScrollView {
            TextField("Name for Group", text: $title)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8.0)
                .textInputAutocapitalization(.never)
                .padding()
            
            HStack {
                switch type {
                case "Home":
                    Image(systemName: "house.fill")
                case "Trip":
                    Image(systemName: "person.3.fill")
                case "Office":
                    Image(systemName: "display")
                case "College":
                    Image(systemName: "person.3.sequence.fill")
                default:
                    Text("Click Button ->")
                }
                if !type.isEmpty {
                    Text("\(type)")
                        .font(.title2)
                }
                Spacer()
                Menu {
                    Button(action: {
                        self.type = "Home"
                    }, label: {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    })
                    Button(action: {
                        self.type = "Trip"
                    }, label: {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text("Trip")
                        }
                    })
                    Button(action: {
                        self.type = "Office"
                    }, label: {
                        HStack {
                            Image(systemName: "display")
                            Text("Office")
                        }
                    })
                    Button(action: {
                        self.type = "College"
                    }, label: {
                        HStack {
                            Image(systemName: "person.3.sequence.fill")
                            Text("College")
                        }
                    })
                } label: {
                    Text("Select Group Type:")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            }
            .padding(.horizontal)
            
            Text("Members in the Group:")
                .padding(.top)
            
            LazyVGrid(columns: colums, alignment: .center) {
                
                ForEach(members) { member in
                    
                    AsyncImage(url: URL(string: member.imageURL), transaction: .init(animation: .spring())) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .frame(height: 40.0)
                        case .failure(let error):
                            Text("Image not Found! \(error.localizedDescription)")
                        @unknown default:
                            Text("User Image not Found!")
                        }
                    }
                    .shadow(radius: 10)
                        
                }
            }
            .padding()
            
            Button {
                show.toggle()
            } label: {
                Text("Add Members:")
            }
            .padding()
            
            Button {
                SaveGroup()
            } label: {
                Text("Save Group")
            }
            .padding()
            .foregroundStyle(Color.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            
        }
        .navigationTitle("New Group")
        .sheet(isPresented: $show) {
            NavigationView {
                GroupFriendsView(members: $members)
            }
        }
        .onAppear {
            getUser()
        }
    }
    
    private func getUser() {
        
        let uid : String = UserDefaults.standard.object(forKey: "uid") as! String
        let email : String = UserDefaults.standard.object(forKey: "email") as! String
        let imageURL : String = UserDefaults.standard.object(forKey: "imageURL") as! String
        members.append(User(uid: uid, imageURL: imageURL, email: email))
        
    }
    
    private func SaveGroup() {
        
        var mem : [String] = []
        for member in members {
            mem.append(member.email)
        }
        
        let groupData = [
            "name" : self.title,
            "type" : self.type,
            "members" : mem
        ] as [String : Any]
        
        let groupuid = UUID().uuidString
        
        FirebaseManager.shared.firestore.collection("groups")
            .document(groupuid).setData(groupData, completion: { error in
                if let err = error {
                    print("Error in adding groups \(err)")
                    return
                }
                print("Success to create users data")
            })
        let data = [
            "owe" : [],
            "total" : 0.0
        ] as [String : Any]
        for member in members {
            FirebaseManager.shared.firestore.collection("groups")
                .document(groupuid).collection("values").document(member.email).setData(data) { error in
                    if let err = error {
                        print("Error in adding values in groups data \(err)")
                        return
                    }
                    print("Success to create users data")
                }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    NavigationView {
        AddGroupView()
    }
}
