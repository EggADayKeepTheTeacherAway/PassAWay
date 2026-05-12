//
//  PostDetailView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI
import FirebaseCore

struct PostDetailView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("PassBackground")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Hero Image
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            Color.clear
                                .overlay(
                                    AsyncImage(url: URL(string: item.photoUrl)) { image in image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ZStack {
                                            Color("PassLightGreen")
                                            ProgressView().tint(Color("PassPrimary"))
                                        }
                                    }
                                )
                                .frame(width: geo.size.width, height: 300)
                                .clipped()
                            }
                            .frame(height: 300)

                            BackButton()
                                .padding(.top, 52)
                                .padding(.leading, 20)
                                .buttonStyle(.plain)
                    }

                    // MARK: Content Card
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Title & Profile Pill
                        VStack(alignment: .leading, spacing: 8) {
                                                    
                            // 1. Title
                            Text(item.title)
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(Color("PassPrimary"))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                                                    
                            // 2. Profile Pill
                            NavigationLink(destination: PublicProfileView(userId: item.giverId)) {
                                HStack(spacing: 8) {
                                    UserAvatarView(userId: item.giverId, size: 24)
                                                            
                                    Text("View Profile")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color("PassPrimary"))
                                                        
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color("PassPrimary").opacity(0.6))
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color("PassLightGreen").opacity(0.4))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                        Divider()
                            .background(Color("PassPrimary").opacity(0.1))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        // Description
                        Text(item.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("PassPrimary").opacity(0.75))
                            .lineSpacing(5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                        // MARK: Meta rows
                        VStack(spacing: 12) {
                            MetaRow(label: "Category", value: item.category)
                            MetaRow(label: "Condition", value: item.condition)
                            MetaRow(label: "Pickup Area", value: item.pickUpArea)
                            MetaRow(label: "Status", value: item.status.capitalized)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                    .background(Color("PassBackground"))
                }
            }
            .ignoresSafeArea(edges: .top)

            // MARK: Request Button
            VStack(spacing: 0) {
                Divider().background(Color("PassPrimary").opacity(0.08))
                Button(action: {
                    // Claim flow — coming later
                }) {
                    Text("Request for this Item")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("PassPrimary"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color("PassBackground"))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Meta Row

struct MetaRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("PassPrimary").opacity(0.5))
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("PassPrimary"))

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(item: Item(
            giverId: "user123",
            photoUrl: "",
            title: "White T-Shirt",
            description: "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
            category: "Clothes",
            condition: "Brand New",
            pickUpArea: "Kasetsart",
            latitude: 13.8475, 
            longitude: 100.5696,
            status: "Available",
            claimedBy: nil,
            createdAt: .init()
        ))
    }
}
