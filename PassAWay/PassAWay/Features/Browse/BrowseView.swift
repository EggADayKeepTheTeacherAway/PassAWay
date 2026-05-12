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
    
    let categories = ["All", "Clothes", "Food", "Electronics", "Books", "Household", "Other"]
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
                    HStack {
                        Text("Browse")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(Color("PassPrimary"))
                        
                        Spacer()
                        
                        // Clear Search Button (Only shows if they searched something)
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // Search Bar Button
                    Button(action: {
                        isSearchActive = true
                    }) {
                        SearchBar(text: $viewModel.searchText)
                            .allowsHitTesting(false)
                    }
                    .padding(.horizontal, 25)
                    .navigationDestination(isPresented: $isSearchActive) {
                        // Pass the binding into SearchView!
                        SearchView(activeSearchText: $viewModel.searchText)
                    }
                    
                    // MARK: - Categories & Sorting
                    VStack(spacing: 15) {
                        
                        // Category Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        viewModel.selectedCategory = category // Updates ViewModel!
                                    }) {
                                        Text(category)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(viewModel.selectedCategory == category ? Color("PassPrimary") : Color("PassLightGreen"))
                                            .foregroundColor(viewModel.selectedCategory == category ? .white : Color("PassPrimary"))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // Sort Dropdown
                        HStack {
                            Text(viewModel.searchText.isEmpty ? "Showing:" : "Results for '\(viewModel.searchText)':")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Menu {
                                ForEach(sortOptions, id: \.self) { option in
                                    Button(option) { viewModel.selectedSort = option }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.selectedSort)
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
                    } else if viewModel.filteredItems.isEmpty {
                        // Shows if a search or category returns 0 results
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No items found.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.filteredItems) { item in
                                    NavigationLink(destination: PostDetailView(item: item)) {
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
