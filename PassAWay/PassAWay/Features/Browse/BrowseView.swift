//
//  BrowseView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct BrowseView: View {
    @State private var isSearchActive: Bool = false
    
    // MARK: - Filter & Sort States
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Clothes", "Food", "Electronics", "Books", "Household"]
    
    @State private var selectedSort: String = "Recently Added"
    let sortOptions = ["Recently Added", "Near Me", "Everywhere"]
    
    // Mock Data
    let mockItems = [
        "White T-shirt", "White T-shirt 1",
        "White T-shirt 2", "White T-shirt 3",
        "Nike Backpack", "Green Ipad"
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PassBackground").ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    Text("Browse")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    
                    // Search Bar Button
                    Button(action: {
                        isSearchActive = true
                    }) {
                        SearchBar(text: .constant(""))
                            .allowsHitTesting(false)
                    }
                    .padding(.horizontal, 25)
                    .navigationDestination(isPresented: $isSearchActive) {
                        SearchView()
                    }
                    
                    // MARK: - Categories & Sorting
                    VStack(spacing: 15) {
                        
                        // Category Pills (Horizontal Scroll)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            // Highlight if selected, light green if not
                                            .background(selectedCategory == category ? Color("PassPrimary") : Color("PassLightGreen"))
                                            .foregroundColor(selectedCategory == category ? .white : Color("PassPrimary"))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                        
                        // Sort / Location Dropdown Menu
                        HStack {
                            Text("Showing:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(sortOptions, id: \.self) { option in
                                    Button(option) { selectedSort = option }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedSort)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption2)
                                        .foregroundColor(Color("PassPrimary"))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 25)
                    }
                    
                    // MARK: - Grid Content
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(mockItems, id: \.self) { item in
                                GridItemCard(title: item)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 5)
                        .padding(.bottom, 100)
                    }
                }
                
                // Bottom Tab Bar
                VStack {
                    Spacer()
                    TabBarView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    BrowseView()
}
