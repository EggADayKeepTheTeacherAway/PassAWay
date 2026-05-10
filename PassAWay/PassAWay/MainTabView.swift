//
//  MainTabView.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. The Active View
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    BrowseView()
                case 2:
                    Text("Chat Feature Coming Soon!") // Placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("PassBackground").ignoresSafeArea())
                case 3:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            .padding(.bottom, 60)
            
            // 2. The Shared Tab Bar
            TabBarView(selected: $selectedTab)
        }
        .ignoresSafeArea(.keyboard) // Keeps the tab bar out of the way when typing
    }
}
