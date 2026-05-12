//
//  SearchView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    
    // Connects back to the BrowseViewModel's search text!
    @Binding var activeSearchText: String
    
    @State private var localSearchText: String = ""
    
    // Real permanent storage for history
    @State private var searchHistory: [String] = UserDefaults.standard.stringArray(forKey: "SearchHistory") ?? []
    
    var body: some View {
        ZStack {
            Color("PassBackground").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                
                // Header
                Text("Search")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("PassPrimary"))
                    .padding(.top, 10)
                
                // Active Search Bar & Cancel Button
                HStack(spacing: 12) {
                    SearchBar(text: $localSearchText) {
                        performSearch(query: localSearchText)
                    }
                    
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("PassPrimary"))
                        .font(.callout)
                        .fontWeight(.medium)
                }
                
                // History Section
                if !searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Search History")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("PassPrimary"))
                            Spacer()
                            Button("Clear all") {
                                searchHistory.removeAll()
                                saveHistory()
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PassPrimary").opacity(0.7))
                        }
                        
                        // History List
                        ForEach(searchHistory, id: \.self) { term in
                            HStack {
                                // Tapping a history item searches for it immediately
                                Button(action: { performSearch(query: term) }) {
                                    Text(term)
                                        .foregroundColor(Color("PassPrimary").opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    searchHistory.removeAll { $0 == term }
                                    saveHistory()
                                }) {
                                    Text("x")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color("PassPrimary").opacity(0.6))
                                        .padding(.horizontal, 5)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 25)
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load the current search text if they come back to edit it
            localSearchText = activeSearchText
        }
    }
    
    // MARK: - Search Actions
    private func performSearch(query: String) {
        let cleanQuery = query.trimmingCharacters(in: .whitespaces)
        if !cleanQuery.isEmpty {
            // Add to top of history, remove duplicates
            searchHistory.removeAll { $0 == cleanQuery }
            searchHistory.insert(cleanQuery, at: 0)
            saveHistory()
            
            // Pass the data back and close the sheet
            activeSearchText = cleanQuery
            dismiss()
        }
    }
    
    private func saveHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "SearchHistory")
    }
}

