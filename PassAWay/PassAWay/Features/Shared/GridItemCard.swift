//
//  GridItemCard.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//


import SwiftUI

struct GridItemCard: View {
    var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Placeholder
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("PassLightGreen"))
                .aspectRatio(1, contentMode: .fit) 
            
            // Item Title
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("PassPrimary"))
                .lineLimit(1)
        }
    }
}
