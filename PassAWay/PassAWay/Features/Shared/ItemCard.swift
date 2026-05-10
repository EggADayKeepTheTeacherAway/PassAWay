//
//  ItemCard.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI


struct ItemCard: View {
    let item: Item
    @State private var pressed = false
    
    var body: some View {
        NavigationLink(destination: PostDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 0) {            // Image placeholder
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: item.photoUrl)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color("PassLightGreen")
                    }
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)

                    // Avatar
                    Circle()
                        .fill(Color("PassPrimary"))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        )
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("PassPrimary"))
                        .lineLimit(1)
                    
                    Text(item.description)
                        .font(.system(size: 11))
                        .foregroundColor(Color("PassPrimary").opacity(0.6))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {}) {
                        Text("See more")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("PassPrimary"))
                            .cornerRadius(6)
                    }
                    .padding(.top, 4)
                }
                .padding(10)
            }
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color("PassPrimary").opacity(0.08), radius: 8, x: 0, y: 3)
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: pressed)
        }
    }
}
