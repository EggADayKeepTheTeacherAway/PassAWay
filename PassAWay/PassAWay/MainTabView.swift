//
//  MainTabView.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingCreatePost = false // NEW: Tracks if the create view is open
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. The Active View
            Group {
                switch selectedTab {
                case 0:
                    HomeView(selectedTab: .constant(0))
                case 1:
                    BrowseView()
                case 2:
                    Text("Chat Feature Coming Soon!") // Placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("PassBackground").ignoresSafeArea())
                case 3:
                    ProfileView()
                default:
                    HomeView(selectedTab: .constant(0))
                }
            }
            .padding(.bottom, 60)
            
            // 2. The Shared Tab Bar
            TabBarView(selected: $selectedTab, onAddTapped: {
                // When the center button is tapped, toggle the state!
                showingCreatePost = true
            })
        }
        .ignoresSafeArea(.keyboard)
        // 3. Present the CreatePostView over the entire screen
        .fullScreenCover(isPresented: $showingCreatePost) {
            CreatePostView()
        }
    }
}

#Preview {
    MainTabView()
}
