//
//  SearchView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    
    // Mock Search History
    @State private var searchHistory: [String] = [
        "White T-shirt",
        "White T-shirt 1",
        "White T-shirt 2",
        "White T-shirt 3"
    ]
    
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
                    SearchBar(text: $searchText) {
                        // Action when user presses 'Return' on keyboard
                        if !searchText.isEmpty {
                            searchHistory.insert(searchText, at: 0)
                            searchText = ""
                        }
                    }
                    
                    // Sleeker Cancel Button
                    Button("Cancel") {
                        dismiss()
                    }
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
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PassPrimary").opacity(0.7))
                        }
                        
                        // History List
                        ForEach(searchHistory, id: \.self) { term in
                            HStack {
                                Text(term)
                                    .foregroundColor(Color("PassPrimary").opacity(0.8))
                                
                                Spacer()
                                
                                Button(action: {
                                    searchHistory.removeAll { $0 == term }
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
    }
}

#Preview {
    SearchView()
}
