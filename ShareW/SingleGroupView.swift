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
    
    @State var logsarray : [Logs] = []
    
    var body: some View {
        ScrollView {
            HStack {
                //                //Text("Welcome \(email.replacingOccurrences(of: "@gmail.com", with: "").capitalized)")
                //                    .font(.title2)
                //                    .padding(.horizontal)
                Text("Welcome to the \(group.title) Group!")
                    .font(.title2)
                    .padding(.horizontal)
                Spacer()
            }
            if group.oweMoney.isEmpty {
                Text("No expensed Added!")
                    .padding()
            } else {
                HStack {
                    Text(group.value < 0 ? "You Owe!" : "You Get!")
                    Spacer()
                    VStack {
                        ForEach(group.oweMoney, id: \.self) { value in
                            Text(value.keys.description)
                        }
                    }
                }
                .padding()
                .foregroundStyle(group.value < 0 ? Color.red : Color.green)
                Text("Total \(group.value)")
                    .foregroundStyle(group.value < 0 ? Color.red : Color.green)
            }
            
            ForEach(group.members, id: \.self) { mem in
                Text(mem)
            }
            
            
            ForEach(logsarray, id: \.id) { log in
                
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
                }
                .padding(.horizontal)
                Spacer()
            }
            
        }
        .onAppear(perform: {
            getUserDebts()
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
        SingleGroupView(group: .constant(Group(uid: "", title: "", type: "", value: 0.0, members: [""],oweMoney: [])))
    }
}
