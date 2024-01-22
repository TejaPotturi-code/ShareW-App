//
//  SingleGroupView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/10/24.
//

import SwiftUI

struct SingleGroupView: View {
    
    @Binding var group: Group
    @State var email: String = ""
    @State var showMembers: Bool = false
    
    @State var logsarray : [Logs] = []
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Welcome to the \(group.title) Group!")
                    .font(.title2)
                    .padding(.horizontal)
                Spacer()
            }
            if group.oweMoney.isEmpty {
                Text("No expensed Added!")
                    .padding()
            } else {
                ForEach(group.oweMoney, id: \.self) { dictionary in
                    let GetDictionary = dictionary.filter { $0.value >= 0 }
                    let OweDictionary = dictionary.filter { $0.value < 0 }
                    if GetDictionary.count > 0 {
                        HStack {
                            Text("You Get!")
                            Spacer()
                            VStack {
                                ForEach(GetDictionary.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { key, value in
                                            
                                    Text("\(key)  $\(value)")
                                }
                                if GetDictionary.count > 3 {
                                    HStack {
                                        Spacer()
                                        Text("..See More")
                                            .font(.callout)
                                            .foregroundStyle(Color.blue)
                                    }
                                    
                                }
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.green)
                    }
                    
                    if OweDictionary.count > 0 {
                        HStack {
                            Text("You Owe!")
                            Spacer()
                            VStack {
                                ForEach(OweDictionary.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { key, value in
                                            
                                    Text("\(key) $\(value)")
                                }
                                if OweDictionary.count > 3 {
                                    HStack {
                                        Spacer()
                                        Text("..See More")
                                            .font(.callout)
                                            .foregroundStyle(Color.blue)
                                    }
                                }
                            }
                        }
                        .padding()
                        .foregroundStyle(Color.red)
                    }
                }
                Text("Total \(group.value)")
                    .foregroundStyle(group.value < 0 ? Color.red : Color.green)
            }
            
            
            
            
            ForEach(logsarray, id: \.id) { log in
                
                Divider()
                HStack {
                    Text("\(log.title.capitalized)")
                    Spacer()
                    if log.addedBy == email {
                        VStack {
                            Text("You Get!")
                            if log.addedTo.contains(email) {
                                Text("\(String(log.total - log.eachShare))")
                            } else {
                                Text("\(String(log.total))")
                            }
                        }
                        .foregroundStyle(Color.green)
                    } else {
                        VStack {
                            Text("You Owe!")
                            if log.addedTo.contains(email) {
                                Text("\(String(log.eachShare))")
                            } else {
                                Text("You Don't Owe Anything")
                            }
                            
                        }
                        .foregroundStyle(Color.red)
                    }
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal)
                Spacer()
            }
            Divider()
        }
        .onAppear(perform: {
            getUserDebts()
        })
        .sheet(isPresented: $showMembers, content: {
            
            NavigationView(content: {
                List {
                    Section("Members:") {
                        ForEach(group.members, id: \.self) { mem in
                            Text(mem)
                        }
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            showMembers.toggle()
                        } label: {
                            Text("Close")
                        }
                        
                    }
                })
            })
            
            
        })
        .scrollIndicators(.hidden)
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                
                
                NavigationLink {
                    ExpenseView(group: $group, email: $email)
                } label: {
                    Text("Add Expense")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15.0))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMembers.toggle()
                } label: {
                    Image(systemName: "person.2.badge.gearshape.fill")
                }
                .foregroundStyle(Color.primary)
                
            }
            
        })
    }
    
    private func getUserDebts() {
        self.email = UserDefaults.standard.object(forKey: "email") as! String
        
        FirebaseManager.shared.firestore.collection("groups").document(group.uid)
            .collection("values").document(email).getDocument { DocumentSnapshot, Error in
                if let err = Error {
                    print("Error \(err)")
                    return
                }
                let data = DocumentSnapshot?.data()
                group.oweMoney = data!["owe"] as! [[String : Double]]
                group.value = data!["total"] as! Double
            }
        
        FirebaseManager.shared.firestore.collection("groups").document(group.uid)
            .collection("logs").getDocuments { QuerySnapshot, Error in
                if let err = Error {
                    print("Error \(err)")
                    return
                }
                
                self.logsarray = []
                
                QuerySnapshot?.documents.forEach({ (documentSnapshot) in
                    
                    let documentData = documentSnapshot.data()
                    
                    let docId = documentSnapshot.documentID
                    let total =  documentData["total"] as? Double
                    let title =  documentData["title"] as? String
                    let addedBy =  documentData["AddedBy"] as? String
                    let eachshare =  documentData["eachshare"] as? Double
                    let addedTo =  documentData["AddedTo"] as? [String]
                    
                    logsarray.append(Logs(id: docId, total: total!, title: title!, addedBy: addedBy!, eachShare: eachshare!, addedTo: addedTo!))
                })
            }
        
    }
}

class Logs: Identifiable {
    var id: String
    var total: Double
    var title: String
    var addedBy: String
    var eachShare: Double
    var addedTo: [String]
    
    init(id: String, total: Double, title: String, addedBy: String, eachShare: Double, addedTo: [String]) {
        self.id = id
        self.total = total
        self.title = title
        self.addedBy = addedBy
        self.eachShare = eachShare
        self.addedTo = addedTo
    }
    
}

#Preview {
    NavigationStack {
        SingleGroupView(group: .constant(Group(uid: "0DF433A0-5172-4AA0-A74F-EAE56E345BEB", title: "Test", type: "College", value: 20.0, members: ["share@gmail.com", "share3@gmail.com"],oweMoney: [["share3@gmail.com": 20.0]])))
    }
}
