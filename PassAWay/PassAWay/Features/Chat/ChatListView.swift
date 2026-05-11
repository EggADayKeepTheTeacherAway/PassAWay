//
//  ChatListView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @State private var selectedChat: Chat? = nil

    var body: some View {
        ZStack {
            Color("PassBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Chat")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("PassPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                Divider()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Color("PassPrimary"))
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
                        Button(action: { viewModel.refresh() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color("PassPrimary"))
                            .cornerRadius(10)
                        }
                    }
                    Spacer()

                } else {
                    List(viewModel.chats) { chat in
                        ChatRow(chat: chat)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color("PassBackground"))
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedChat = chat
                            }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
        }
        .navigationDestination(item: $selectedChat) { chat in
            ChatDetailView(chat: chat)
        }
        .onAppear {
            viewModel.listenToChats()
        }
    }
}

// MARK: - Chat List View Model

@MainActor
private final class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    
    let currentUserId = Auth.auth().currentUser?.uid ?? ""

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func refresh() {
        isLoading = true
        listener?.remove()
        listener = nil
        chats = []
        listenToChats()
        isLoading = false
    }

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
                if let error {
                    print("❌ error: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                self.chats = []
                for doc in snapshot?.documents ?? [] {
                    do {
                        let chat = try doc.data(as: Chat.self)
                        self.chats.append(chat)
                        print("✅ Decoded chat: \(chat.id ?? "no id")")
                    } catch {
                        print("❌ Failed to decode chat \(doc.documentID): \(error)")
                    }
                }
                self.isLoading = false
            }
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
            let user = try doc.data(as: User.self)
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

