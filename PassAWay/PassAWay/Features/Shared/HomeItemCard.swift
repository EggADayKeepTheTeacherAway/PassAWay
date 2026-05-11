//
//  HomeItemCard.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


//
//  HomeItemCard.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI

struct HomeItemCard: View {
    let item: Item

    var body: some View {
        NavigationLink(destination: PostDetailView(item: item)) {
            VStack(alignment: .leading, spacing: 0) {

                // Image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: item.photoUrl)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color("PassLightGreen")
                    }
                    .frame(width: 260, height: 280)
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

            }
            .frame(width: 260)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color("PassPrimary").opacity(0.08), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
