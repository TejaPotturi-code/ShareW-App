//
//  TabBarView.swift
//  ShareW
//
//  Created by Teja Potturi on 1/1/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var isLogin: Bool
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex,
                content:  {
            
            NavigationView(content: {
                GroupView()
            })
            .tabItem {
                Image(systemName: "house.fill")
            }
            .tag(0)
            
            NavigationView(content: {
                FriendsView()
            })
            .tabItem {
                Image(systemName: "person.crop.circle.fill.badge.plus")
            }
            .tag(1)
            
            AccountView(isLogin: $isLogin)
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(2)
        })
    }
}

#Preview {
    TabBarView(isLogin: .constant(true))
}
