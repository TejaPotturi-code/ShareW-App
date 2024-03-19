//
//  ExpenseView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/11/24.
//

import SwiftUI
import FirebaseFirestore

struct ExpenseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var group: Group
    @Binding var email: String
    @State var name: String = ""
    @State var value: String = ""
    @State var showAddMembers: Bool = false
    @State var friends : [String] = []
    @State var aaddfriends : [String] = []
    
    var body: some View {
        ScrollView {
            TextField("Name of the expense", text: $name)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8.0)
                .padding(.bottom, 20)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
            
            TextField("Value of the expense", text: $value)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8.0)
                .padding(.bottom, 20)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
            
            HStack {
                Text("Edit Members for Expense ->")
                Button(action: {
                    showAddMembers.toggle()
                }, label: {
                    Text("Edit")
                })
                .buttonStyle(.bordered)
            }
            Button(action: {
                
                saveExpense()
                
            }, label: {
                Text("Save Expense")
            })
            .padding()
            .buttonStyle(.borderedProminent)
            
        }
        .onAppear(perform: {
            self.friends = group.members
        })
        .navigationTitle("Add Expense")
        .sheet(isPresented: $showAddMembers, content: {
            List {
                Section("Added") {
                    ForEach(self.friends, id: \.self) { friend in
                        Text(friend.description)
                            .shadow(color: .green, radius: 10)
                            .onTapGesture {
                                aaddfriends.append(friend)
                                friends.removeAll(where: { $0 == friend })
                            }
                    }
                }
                Section("Add") {
                    ForEach(self.aaddfriends, id: \.self) { friend in
                        Text(friend.description)
                            .shadow(radius: 10)
                            .onTapGesture {
                                friends.append(friend)
                                aaddfriends.removeAll(where: { $0 == friend })
                            }
                    }
                }
            }
        })
    }
    
    private func addExpenseEachFriend(friend: String,doubleValue: Double,eachshare: Double) {
        
        var data = [
            "total": 0.0,
            "owe":[],
        ] as [String : Any]
        FirebaseManager.shared.firestore.collection("groups").document(group.uid)
            .collection("values")
            .document(friend).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    return
                }
                
                if var tota = document["total"] as? Double {
                    if friend != email {
                        tota = tota - eachshare
                    }
                    data["total"] = tota
                }
                
                if var fieldValue = document["owe"] as? [[String: Double]] {
                    print("owe",fieldValue)
                    if friend != email {
                        if let rowIndex = fieldValue.firstIndex(where: { $0.keys.contains(email) }) {
                            fieldValue[rowIndex][email]! -= eachshare
                            print("Updated value for \(friend): \(eachshare)")
                        } else {
                            print("\(friend) not found in the 2D array1.")
                            fieldValue.append([email : -eachshare])
                        }
                    }
                    data["owe"] = fieldValue
                }
                
                FirebaseManager.shared.firestore.collection("groups").document(group.uid)
                    .collection("values")
                    .document(friend).updateData(data) { Error in
                        if let err = Error {
                            print("Error in saving data \(err)")
                        }
                        print("Success")
                    }
            }
        
    }
    
    private func saveExpensestoCurrentUser(doubleValue: Double,eachshare: Double) {
        var data = [
            "total": 0.0,
            "owe":[],
        ] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("groups").document(group.uid)
            .collection("values")
            .document(email).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    return
                }
                if var tota = document["total"] as? Double {
                    if friends.contains(where: {$0 == email}) {
                        tota += doubleValue - eachshare
                    } else {
                        tota += doubleValue
                    }
                    data["total"]=tota
                }
                
                if var fieldValue = document["owe"] as? [[String: Double]] {
                    print("Teja test",fieldValue)
                    for frie in friends {
                        if frie != email {
                            if let rowIndex = fieldValue.firstIndex(where: { $0.keys.contains(frie) }) {
                                fieldValue[rowIndex][frie]! += eachshare
                                print("Updated value for \(frie): \(eachshare)")
                            } else {
                                print("\(frie) not found in the 2D array2.")
                                fieldValue.append([frie : eachshare])
                            }
                        }
                    }
                    data["owe"]=fieldValue
                }
                
                FirebaseManager.shared.firestore.collection("groups").document(group.uid)
                    .collection("values")
                    .document(email).updateData(data) { Error in
                        if let err = Error {
                            print("Error in saving data \(err)")
                        }
                        print("Success in adding owes")
                        self.presentationMode.wrappedValue.dismiss()
                    }
            }
    }
    
    private func saveExpense() {
        
        if let doubleValue = Double(self.value) {
            let eachshare = doubleValue / Double(self.friends.count)
            
            for friend in friends {
                addExpenseEachFriend(friend: friend,doubleValue: doubleValue,eachshare: eachshare)
            }
            
            saveExpensestoCurrentUser(doubleValue: doubleValue, eachshare: eachshare)
            
            saveLog(doubleValue: doubleValue, eachshare: eachshare)
            
            print("Each Share \(eachshare)")
            return
        }
        print("Cannot convert")
        
    }
    
    private func saveLog(doubleValue: Double, eachshare: Double) {
        
        let expenseUID : String = UUID().uuidString
        
        let data = [
            "title": name,
            "total": doubleValue,
            "eachshare": eachshare,
            "AddedBy": email,
            "AddedTo": friends
        ] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("groups").document(group.uid)
            .collection("logs")
            .document(expenseUID).setData(data) { Error in
                if let err = Error {
                    print("Error in saving data \(err)")
                }
                print("Success to add logs")
            }
    }
}

#Preview {
    NavigationView {
        ExpenseView(group: .constant(Group(uid: "", title: "", type: "", value: 0, members: [], oweMoney: [])), email: .constant(""))
    }
    
}
