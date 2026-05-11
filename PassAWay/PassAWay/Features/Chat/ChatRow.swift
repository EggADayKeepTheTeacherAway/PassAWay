//
//  ChatRow.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 11/5/26.
//
import SwiftUI
import FirebaseFirestore


struct ChatRow: View {
    let chat: Chat
    let currentUserId = "szjx9ml8XhgFsEDBgEnH8L3DYPq1"
    @StateObject private var userFetcher = UserFetcher()

    var otherUserId: String {
        chat.participants.first { $0 != currentUserId } ?? ""
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color("PassLightGreen"))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("PassPrimary"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(userFetcher.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("PassPrimary"))
                    .lineLimit(1)

                Text(chat.lastMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Color("PassPrimary").opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            Text(chat.lastUpdated.dateValue().timeAgoDisplay())
                .font(.system(size: 11))
                .foregroundColor(Color("PassPrimary").opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color("PassBackground"))
        .task(id: otherUserId) {
            await userFetcher.fetch(userId: otherUserId)
        }
    }
}
