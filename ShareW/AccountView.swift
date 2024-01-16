//
//  AccountView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/1/24.
//

import SwiftUI

struct AccountView: View {
    
    @Binding var isLogin: Bool
    
    @State var email: String = ""
    @State var imageURL: String = ""
    
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: imageURL.description), transaction: .init(animation: .spring())) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    UserImageView(image: image)
                case .failure(let error):
                    Text("Image not Found! \(error.localizedDescription)")
                @unknown default:
                    Text("User Image not Found!")
                }
            }
            .frame(width: 200, height: 200)
            
            List {
                
                Section {
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(email)
                    }
                    .font(.title3)
                    HStack {
                        Text("Number:")
                        Spacer()
                        Text("xxx-xxx-xxxx")
                    }
                    .font(.title3)
                    
                } header: {
                    Text("Account Info")
                        .font(.headline)
                }
                
                
                Section {
                    
                    NavigationLink {
                        Text("Here Comes")
                    } label: {
                        Text("Update Password")
                    }
                    .font(.title3)
                    NavigationLink {
                        Text("Here Comes")
                    } label: {
                        Text("Update Number")
                    }
                    .font(.title3)
                    
                } header: {
                    Text("Update")
                        .font(.headline)
                }
                
                Section {
                    
                    NavigationLink {
                        Text("Here Comes")
                    } label: {
                        Text("Rating for ShareW")
                    }
                    .font(.title3)
                    NavigationLink {
                        Text("Here Comes")
                    } label: {
                        Text("Contact us")
                    }
                    .font(.title3)
                    
                } header: {
                    Text("About us")
                        .font(.headline)
                }
                
                Text("Created with :),By Teja in Lubbock,\n United States")
                    .multilineTextAlignment(.center)
                
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            Button {
                isLogin.toggle()
            } label: {
                Text("Logout")
                    .font(.headline)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 50.0))
                    .padding()
            }
        }
        .onAppear(perform: {
            getUserDetails()
        })
    }
    
    private func getUserDetails() {

        let uid : String = UserDefaults.standard.object(forKey: "uid") as! String
        self.email = UserDefaults.standard.object(forKey: "email") as! String
        self.imageURL = UserDefaults.standard.object(forKey: "imageURL") as! String
    }
    
}


struct UserImageView : View {
    
    var image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 150,height: 150)
            .clipShape(Circle())
            .padding()
    }
}


#Preview {
    AccountView(isLogin: .constant(true))
    //    var image = AsyncImage(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/sharew-2dfae.appspot.com/o/lD0Aj1HjNvNiHXwmkpx13xHVs0z1?alt=media&token=9408654e-866f-42e1-b468-edd9b2257ebb")) { image in
    //        UserImageView(image: image)
    //    } placeholder: {
    //        Color.green
    //    }
}
