//
//  ChatListView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


import SwiftUI
import FirebaseFirestore
import Combine

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("PassBackground")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    Text("Chat")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("PassPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    Divider()
                        .background(Color("PassPrimary").opacity(0.1))

                    // MARK: Content
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(Color("PassPrimary"))
                        Spacer()

                    } else if viewModel.chats.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 48))
                                .foregroundColor(Color("PassPrimary").opacity(0.2))
                            Text("No conversations yet.")
                                .font(.system(size: 14))
                                .foregroundColor(Color("PassPrimary").opacity(0.5))
                        }
                        Spacer()

                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.chats) { chat in
                                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                                        ChatRow(chat: chat)
                                    }
                                    .buttonStyle(.plain)

                                    Divider()
                                        .background(Color("PassPrimary").opacity(0.08))
                                        .padding(.leading, 76)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.listenToChats()
            }
        }
    }
}

// MARK: - Chat Row

struct ChatRow: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 14) {

            // Avatar
            Circle()
                .fill(Color("PassLightGreen"))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("PassPrimary"))
                )

            // Name + last message
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.itemId)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("PassPrimary"))
                    .lineLimit(1)

                Text(chat.lastMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Color("PassPrimary").opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            // Timestamp
            Text(chat.lastUpdated.dateValue().timeAgoDisplay())
                .font(.system(size: 11))
                .foregroundColor(Color("PassPrimary").opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color("PassBackground"))
    }
}

// MARK: - ViewModel

@MainActor
private final class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func listenToChats() {
        guard listener == nil else { return }
        isLoading = true

        // TODO: replace with Auth.auth().currentUser?.uid
        let currentUserId = "BC3vz9m9FffzWrMlf6SKGPRptO92"

        listener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("❌ Chat fetch error: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                self.chats = []
                for doc in snapshot?.documents ?? [] {
                    do {
                        let chat = try doc.data(as: Chat.self)
                        self.chats.append(chat)
                    } catch {
                        print("❌ Failed to decode chat \(doc.documentID): \(error)")
                    }
                }
                self.isLoading = false
            }
    }

    deinit {
        listener?.remove()
    }
}

// MARK: - Date Helper

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        if seconds < 60 { return "now" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86400 { return "\(seconds / 3600)h" }
        return "\(seconds / 86400)d"
    }
}


struct ChatList_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
