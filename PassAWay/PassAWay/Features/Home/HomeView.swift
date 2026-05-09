//
//  HomeView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


import SwiftUI



struct HomeView: View {
    @State private var searchText = ""
    @State private var showSearch = false

    // Sample data
    let recentItems: [Item] = [
        Item(title: "White T-Shirt", description: "Lorem ipsum is simply dummy text of the printing and typesetting industry.", category: "Clothes", condition: "Brand New", pickupArea: "Phaya Thai", imageName: nil, postedBy: "Mansanod Hot", timeAgo: "2m ago"),
        Item(title: "Nike Backpack", description: "Barely used backpack in great condition, perfect for school or travel.", category: "Bags", condition: "Like New", pickupArea: "Lat Phrao", imageName: nil, postedBy: "Sarawut K.", timeAgo: "15m ago"),
        Item(title: "Green iPad", description: "Old iPad still working fine. Great for reading and light tasks.", category: "Electronics", condition: "Good", pickupArea: "Phaya Thai", imageName: nil, postedBy: "Peter N.", timeAgo: "1h ago"),
        Item(title: "Wooden Chair", description: "Solid wood chair, minor scratches. Pick up only.", category: "Furniture", condition: "Fair", pickupArea: "Bang Na", imageName: nil, postedBy: "Nathan J.", timeAgo: "3h ago"),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("PassBackground")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hi, Rattanan 👋")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color("PassBackground"))
                            }
                            Spacer()
                            NotificationBell()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        // MARK: Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("PassPrimary").opacity(0.5))
                                .font(.system(size: 15))
                            Text("Search for an item...")
                                .font(.system(size: 14))
                                .foregroundColor(Color("PassPrimary").opacity(0.45))
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color("SearchBg"))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        .onTapGesture { showSearch = true }

                        // MARK: Recently Added
                        HStack {
                            Text("Recently Added")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("PassPrimary"))
                            Spacer()
                            Button("See all") {
                                // Navigate to browse
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("PassPrimary").opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                        // MARK: Item Grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 14
                        ) {
                            ForEach(recentItems) { item in
                                ItemCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Bottom padding for tab bar
                        Spacer().frame(height: 100)
                    }
                }

                // MARK: Tab Bar
                TabBarView()
            }
        }
        .navigationBarHidden(true)
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.colorScheme, .light)
    }
}
