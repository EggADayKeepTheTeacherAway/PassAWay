//
//  BrowseView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    @State private var isSearchActive: Bool = false
    
    // MARK: - Filter & Sort States
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Clothes", "Food", "Electronics", "Books", "Household"]
    
    @State private var selectedSort: String = "Recently Added"
    let sortOptions = ["Recently Added", "Near Me", "Everywhere"]
    
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
                                            .background(selectedCategory == category ? Color("PassPrimary") : Color("PassLightGreen"))
                                            .foregroundColor(selectedCategory == category ? .white : Color("PassPrimary"))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
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
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("PassPrimary")))
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else if viewModel.items.isEmpty {
                        Spacer()
                        Text("No items found.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.items) { item in
                                    NavigationLink(destination: PostDetailView(item: item)) {
                                        // Make sure your GridItemCard expects an 'Item' object instead of a String!
                                        GridItemCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 5)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    BrowseView()
}
