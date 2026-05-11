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
    @State private var selectedChat: Chat? = nil
    @State private var navigateToChat = false
    
    
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
                                    ChatRow(chat: chat)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedChat = chat
                                            navigateToChat = true
                                        }
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
            .navigationDestination(isPresented: $navigateToChat) {
                if let chat = selectedChat {
                    ChatDetailView(chat: chat)
                }
            }
        }
    }
}

// MARK: - Chat List View Model

@MainActor
private final class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    
    let currentUserId = "szjx9ml8XhgFsEDBgEnH8L3DYPq1"

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func listenToChats() {
        print("🔍 listenToChats called, listener: \(listener != nil ? "exists" : "nil")")
        guard listener == nil else {
            print("⚠️ listener already exists, chats count: \(chats.count)")
            return
        }
        isLoading = true
        print("👤 currentUserId: \(currentUserId)")

        listener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { snapshot, error in
                print("📡 snapshot received, docs: \(snapshot?.documents.count ?? 0), error: \(error?.localizedDescription ?? "none")")
                // rest of code
            }
    }

    deinit {
        listener?.remove()
    }
}


// MARK: - User Fetcher

@MainActor
class UserFetcher: ObservableObject {
    @Published var name = "Loading..."
    
    func fetch(userId: String) async {
        print("🔍 Fetching user: \(userId)")
        guard !userId.isEmpty else {
            print("❌ userId is empty")
            return
        }
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            print("📄 Doc exists: \(doc.exists), data: \(doc.data() ?? [:])")
            let user = try doc.data(as: AppUser.self)
            print("✅ Got user: \(user.name)")
            name = user.name
        } catch {
            print("❌ Failed: \(error)")
            name = "Unknown"
        }
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
        NavigationStack {
            ChatListView()
        }
    }
}

