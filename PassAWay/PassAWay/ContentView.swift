//
//  ContentView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case 0:
                HomeView(selectedTab: $selectedTab)
            case 1:
                BrowseView()
            case 2:
                ChatListView()
            case 3:
                ProfileView()
            default:
                HomeView(selectedTab: $selectedTab)
            }

            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
