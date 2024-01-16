//
//  GroupView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/3/24.
//

class Group: Identifiable {
    
    var id : String {
        self.uid
    }
    var uid: String
    var title: String
    var type: String
    var value : Double
    var members: [String]
    var oweMoney: [[String : Double]]
    
    init(uid: String, title: String, type: String, value: Double, members: [String],oweMoney: [[String : Double]]) {
        self.uid = uid
        self.title = title
        self.type = type
        self.value = value
        self.members = members
        self.oweMoney = oweMoney
    }
}



import SwiftUI

struct GroupView: View {
    
    @State var viewGroup: Bool = false
    @State var show: Bool = false
    
    @State var groups: [Group] = []
    
    @State var email: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                ForEach($groups, id: \.uid) { $group in
                    
                    Divider()
                    NavigationLink {
                        SingleGroupView(group: $group)
                            .navigationTitle("\(group.title)")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Image(systemName: getImageNameForGroup(type: group.type))
                                .resizable()
                                .frame(width: 40,height: 20)
                                .overlay {
                                    Circle()
                                        .stroke(style: StrokeStyle())
                                        .frame(width: 50, height: 50)
                                }
                                .padding([.vertical,.trailing])
//                            Text("\(group.type)")
                            Text("\(group.title)")
                            Spacer()
                            
                            VStack {
                                Text("\(group.value < 0 ? "You Owe!" : "You Get!")")
                                
                                Text(" \(group.value)")
                            }
                            .foregroundStyle(group.value < 0 ? Color.red: Color.green)
                            .padding(.trailing)
                            
                        }
                    }
                    .padding()
                    .foregroundStyle(Color.primary)
                }
                
            }
            .navigationTitle("Groups")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddGroupView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            })
            .onAppear(perform: {
                getAllGroups()
            })
        }
    }
    
    private func getImageNameForGroup(type: String) -> String {
        
        switch type {
        case "Home":
            return "house.fill"
        case "Trip":
            return "person.3.fill"
        case "Office":
            return "display"
        case "College":
            return "person.3.sequence.fill"
        default:
            return "person.3.fill"
        }

    }
    
    private func getAllGroups() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {
            return
        }
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument { snapshot, error in
                if error != nil {
                    print("Testing error in getting data")
                }
                
                let email : String = snapshot?.get("email") as! String
                let imageURL: String = snapshot?.get("imageURL") as! String
                
                UserDefaults.standard.set(uid, forKey: "uid")
                UserDefaults.standard.set(imageURL, forKey: "imageURL")
                
                print("Got ur email \(email)")
                self.email = email
        
                FirebaseManager.shared.firestore.collection("groups")
                    .whereField("members", arrayContains: email).getDocuments { QuerySnapshot, Error in
                        
                        if let err = Error {
                            print("Error \(err)")
                            return
                        }
                        
                        let tempGroups : [Group] = []
                        
                        QuerySnapshot?.documents.forEach({ (documentSnapshot) in
                            let documentData = documentSnapshot.data()
                            let name = documentData["name"] as? String
                            let type = documentData["type"] as? String
                            let members = documentData["members"] as? [String]
                            print("Quote1: \(name ?? "(unknown)")")
                            print("Url1: \(type ?? "(unknown)")")
                            print(members ?? [])
                            
                            let docid = documentSnapshot.documentID
                            print("val \(docid)")
                            
                            FirebaseManager.shared.firestore.collection("groups").document(docid).collection("values").document(email).getDocument { document, Error in
                                if let err = Error {
                                    print("Error \(err)")
                                    return
                                }
                                if let document = document, document.exists {
                                    let title = name ?? "(unknown)"
                                    let type = type ?? "(unknown)"
                                    let data = document.data()
                                    let total = data?["total"]
                                    let owe :[[String : Double]] = data?["owe"] as! [[String : Double]]
                                    print(owe)
                                    print("total \(String(describing: total))")
                                    for val in owe {
                                        print("kdnsfs \(val)")
                                    }
                                    let grp = Group(uid: docid, title: title, type: type, value: total as! Double, members: members ?? [], oweMoney: owe)
                                    if !groups.contains(where: { grp1 in
                                        grp1.uid == grp.uid
                                    }) {
                                        groups.append(grp)
                                    }
                                }
                            }
                            
                            
                            
                        })
                        
                        self.groups = tempGroups
                        
                    }
            }
        
    }
}

#Preview {
    GroupView()
}
