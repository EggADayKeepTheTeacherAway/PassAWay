//
//  SearchBar.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//


import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("PassPrimary").opacity(0.7))
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search for an item...", text: $text, onCommit: onCommit)
                .foregroundColor(Color("PassPrimary"))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color("PassLightGreen"))
        .cornerRadius(10)
    }
}
