//
//  ChatDetailView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


//
//  ChatDetailView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct ChatDetailView: View {
    let chat: Chat
    @StateObject private var viewModel: ChatDetailViewModel
    @State private var messageText = ""

    // TODO: replace with Auth.auth().currentUser?.uid
    let currentUserId = "szjx9ml8XhgFsEDBgEnH8L3DYPq1"

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatId: chat.id ?? ""))
    }

    @State private var otherUserName = "Loading..."

    var otherUserId: String {
        chat.participants.first { $0 != currentUserId } ?? ""
    }
    
    func fetchOtherUser() async {
        guard !otherUserId.isEmpty else { return }
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(otherUserId)
                .getDocument()
            let user = try doc.data(as: User.self)
            otherUserName = user.name
        } catch {
            print("❌ Failed to fetch user \(otherUserId): \(error)")
            otherUserName = "Unknown"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("PassBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack(spacing: 12) {
                    BackButton()
                    Circle()
                        .fill(Color("PassLightGreen"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 15))
                                .foregroundColor(Color("PassPrimary"))
                        )
                    Text(otherUserName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("PassPrimary"))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color("PassBackground"))

                Divider().background(Color("PassPrimary").opacity(0.1))

                // MARK: Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isMe: message.senderId == currentUserId
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .padding(.bottom, 80)
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // MARK: Input Bar
                HStack(spacing: 12) {
                    TextField("Type your message...", text: $messageText)
                        .font(.system(size: 14))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color("SearchBg"))
                        .cornerRadius(20)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(messageText.isEmpty ? Color("PassPrimary").opacity(0.4) : Color("PassPrimary"))
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("PassBackground"))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.listenToMessages()
        }
        .task {
            await fetchOtherUser()
        }
    }

    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.sendMessage(text: messageText, senderId: currentUserId, chatId: chat.id ?? "")
        messageText = ""
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let isMe: Bool

    var body: some View {
        HStack {
            if isMe { Spacer() }

            Text(message.text)
                .font(.system(size: 14))
                .foregroundColor(isMe ? .white : Color("PassPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isMe ? Color("PassPrimary") : Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

            if !isMe { Spacer() }
        }
    }
}

// MARK: - ViewModel

@MainActor
private final class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private let db = Firestore.firestore()
    private let chatId: String
    private var listener: ListenerRegistration?

    init(chatId: String) {
        self.chatId = chatId
    }

    func listenToMessages() {
        guard listener == nil else { return }

        listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("❌ Messages error: \(error.localizedDescription)")
                    return
                }
                self.messages = []
                for doc in snapshot?.documents ?? [] {
                    do {
                        let message = try doc.data(as: Message.self)
                        self.messages.append(message)
                    } catch {
                        print("❌ Failed to decode message \(doc.documentID): \(error)")
                    }
                }
            }
    }

    func sendMessage(text: String, senderId: String, chatId: String) {
        let message = Message(senderId: senderId, text: text, timestamp: Timestamp())
        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(from: message)

            // update lastMessage on chat doc
            db.collection("chats").document(chatId).updateData([
                "lastMessage": text,
                "lastUpdated": Timestamp()
            ])
        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }

    deinit {
        listener?.remove()
    }
}
