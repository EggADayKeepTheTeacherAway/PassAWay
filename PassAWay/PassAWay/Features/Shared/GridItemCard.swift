//
//  GridItemCard.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//


import SwiftUI
import FirebaseFirestore

struct GridItemCard: View {
    var item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Real Image Loader
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: item.photoUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color("PassLightGreen")
                            ProgressView().tint(Color("PassPrimary"))
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // Dynamic Item Title
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("PassPrimary"))
                .lineLimit(1)
        }
    }
}

// MARK: - Preview Setup
struct GridItemCard_Previews: PreviewProvider {
    static var previews: some View {
        GridItemCard(item: Item(
            id: nil,
            giverId: "testUser",
            photoUrl: "https://via.placeholder.com/150",
            title: "Test Bicycle",
            description: "A very nice bike.",
            category: "Other",
            condition: "Good",
            pickUpArea: "Kasetsart",
            latitude: 13.8475,
            longitude: 100.5696,
            status: "Available",
            claimedBy: nil,      
            createdAt: Timestamp(date: Date())
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
