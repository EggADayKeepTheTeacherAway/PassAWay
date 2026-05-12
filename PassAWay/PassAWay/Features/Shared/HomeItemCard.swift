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
                    UserAvatarView(userId: item.giverId, size: 28)
                        .padding(8)
                }

//                // Text below image
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(item.title)
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(Color("PassPrimary"))
//                        .lineLimit(1)
//
//                    Text(item.description)
//                        .font(.system(size: 12))
//                        .foregroundColor(Color("PassPrimary").opacity(0.6))
//                        .lineLimit(2)
//                        .fixedSize(horizontal: false, vertical: true)
//
//                    Text("See more")
//                        .font(.system(size: 11, weight: .semibold))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 5)
//                        .background(Color("PassPrimary"))
//                        .cornerRadius(6)
//                        .padding(.top, 2)
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 10)
//                .frame(width: 260, alignment: .leading)
//                .background(Color.white)
            }
            .frame(width: 260)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color("PassPrimary").opacity(0.08), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
