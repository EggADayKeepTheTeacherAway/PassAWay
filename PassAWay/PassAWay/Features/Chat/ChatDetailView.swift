//
//  ChatDetailView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI
import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

struct ChatDetailView: View {
    let chat: Chat
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ChatDetailViewModel
    @State private var messageText = ""
    @State private var otherUserName = "Loading..."

    private let currentUserId = Auth.auth().currentUser?.uid ?? ""

    private var otherUserId: String {
        chat.participants.first { $0 != currentUserId } ?? ""
    }

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(
            wrappedValue: ChatDetailViewModel(
                chatId: chat.id ?? ""
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            contentView
            inputBar
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.listenToMessages()
        }
        .task {
            await fetchOtherUser()
        }
    }
}

// MARK: - Layout

private extension ChatDetailView {

    var backgroundView: some View {
        Color("PassBackground")
            .ignoresSafeArea()
    }

    var contentView: some View {
        VStack(spacing: 0) {
            headerView

            Divider()
                .background(
                    Color("PassPrimary").opacity(0.1)
                )

            messagesView
        }
    }

    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        
                    // Profile Icon
                    UserAvatarView(userId: otherUserId, size: 36)
                    
                    // Username
                    Text(otherUserName)
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(Color("PassPrimary"))
            }
                
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color("PassBackground"))
    }

    var profileIcon: some View {
        Circle()
            .fill(Color("PassLightGreen"))
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 15))
                    .foregroundColor(Color("PassPrimary"))
            )
    }

    var messagesView: some View {
        ScrollViewReader { proxy in

            ScrollView {
                LazyVStack(spacing: 10) {

                    ForEach(viewModel.messages) { message in
                        messageView(message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 80)
            }
            .onChange(of: viewModel.messages.count) {

                guard let last = viewModel.messages.last else {
                    return
                }

                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    var inputBar: some View {
        HStack(spacing: 12) {

            messageField

            sendButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("PassBackground"))
    }

    var messageField: some View {
        TextField(
            "Type your message...",
            text: $messageText
        )
        .font(.system(size: 14))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color("SearchBg"))
        .cornerRadius(20)
    }

    var sendButton: some View {
        Button(
            action: sendMessage
        ) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(sendButtonColor)
                .clipShape(Circle())
        }
        .disabled(messageText.isEmpty)
    }

    var sendButtonColor: Color {
        messageText.isEmpty
        ? Color("PassPrimary").opacity(0.4)
        : Color("PassPrimary")
    }
}

// MARK: - Message Builders

private extension ChatDetailView {

    @ViewBuilder
    func messageView(_ message: Message) -> some View {

        if message.type ?? "" == "request" {
            requestMessageView(message)
        } else {
            normalMessageView(message)
        }
    }

    func requestMessageView(_ message: Message) -> some View {

        RequestMessageCard(
            message: message,
            itemId: chat.itemId,
            giverId: otherUserId,
            currentUserId: currentUserId,

            onGive: {
                viewModel.respondToRequest(
                    chatId: chat.id ?? "",
                    itemId: chat.itemId,
                    requesterId: otherUserId,
                    accept: true
                )
            },

            onNo: {
                viewModel.respondToRequest(
                    chatId: chat.id ?? "",
                    itemId: chat.itemId,
                    requesterId: otherUserId,
                    accept: false
                )
            }
        )
    }

    func normalMessageView(_ message: Message) -> some View {

        MessageBubble(
            message: message,
            isMe: message.senderId == currentUserId
        )
    }
}

// MARK: - Actions

private extension ChatDetailView {

    func sendMessage() {

        let trimmed = messageText
            .trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            return
        }

        viewModel.sendMessage(
            text: trimmed,
            senderId: currentUserId,
            chatId: chat.id ?? ""
        )

        messageText = ""
    }

    func fetchOtherUser() async {

        guard !otherUserId.isEmpty else {
            return
        }

        do {

            let doc = try await Firestore.firestore()
                .collection("users")
                .document(otherUserId)
                .getDocument()

            let user = try doc.data(as: User.self)

            otherUserName = user.name

        } catch {

            otherUserName = "Unknown"
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {

    let message: Message
    let isMe: Bool

    var body: some View {

        HStack(alignment: .bottom, spacing: 8) {

            if isMe {
                Spacer(minLength: 0)
            } else {
                UserAvatarView(userId: message.senderId, size: 28)
            }

            bubbleContent

            if !isMe {
                Spacer(minLength: 0)
            }
        }
    }
}

private extension MessageBubble {

    var bubbleContent: some View {

        Text(message.text)
            .font(.system(size: 14))
            .foregroundColor(
                isMe
                ? .white
                : Color("PassPrimary")
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isMe
                ? Color("PassPrimary")
                : Color.white
            )
            .cornerRadius(18)
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            )
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

        guard listener == nil else {
            return
        }

        listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self else {
                    return
                }

                if let error {
                    print("❌ Messages error: \(error.localizedDescription)")
                    return
                }

                let decodedMessages = snapshot?.documents.compactMap { doc in

                    do {
                        return try doc.data(as: Message.self)
                    } catch {
                        print("❌ Failed to decode \(doc.documentID)")
                        return nil
                    }

                } ?? []

                self.messages = decodedMessages as! [Message]
            }
    }

    func sendMessage(
        text: String,
        senderId: String,
        chatId: String
    ) {

        let message = Message(
            senderId: senderId,
            text: text,
            timestamp: Timestamp()
        )

        do {

            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(from: message)

            db.collection("chats")
                .document(chatId)
                .updateData([
                    "lastMessage": text,
                    "lastUpdated": Timestamp()
                ])

        } catch {

            print("❌ Failed to send message: \(error)")
        }
    }

    func respondToRequest(
        chatId: String,
        itemId: String,
        requesterId: String,
        accept: Bool
    ) {
        print("respondToRequest: give or no: \(accept)")

        let messageStatus = accept ? "Accepted" : "Rejected"
        let itemStatus = accept ? "Claimed" : "Available"

        // Update item status
        db.collection("items")
            .document(itemId)
            .updateData(["status": itemStatus])

        // Update this chat's request message
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("type", isEqualTo: "request")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error {
                    print("❌ Failed to fetch request message: \(error)")
                    return
                }
                snapshot?.documents.first?.reference.updateData(["status": messageStatus]) { err in
                    if let err { print("❌ \(err)") }
                    else { print("✅ Updated this chat's request to \(messageStatus)") }
                }
            }

        // If accepted, reject all other chats' request messages for this item
        if accept {
            db.collection("chats")
                .whereField("itemId", isEqualTo: itemId)
                .getDocuments { snapshot, error in
                    if let error {
                        print("❌ Failed to fetch other chats: \(error)")
                        return
                    }
                    for doc in snapshot?.documents ?? [] {
                        guard doc.documentID != chatId else { continue } // skip current chat
                        doc.reference
                            .collection("messages")
                            .whereField("type", isEqualTo: "request")
                            .getDocuments { msgSnapshot, _ in
                                for msgDoc in msgSnapshot?.documents ?? [] {
                                    msgDoc.reference.updateData(["status": "Rejected"])
                                }
                            }
                    }
                    print("✅ Rejected all other request messages for item \(itemId)")
                }
            
            let currentUserId = Auth.auth().currentUser?.uid ?? ""
            
            db.collection("users").document(currentUserId).updateData([
                "itemsGivenAway": FieldValue.increment(Int64(1)),
                "xp": FieldValue.increment(Int64(50))
            ])
        }
    }

    deinit {
        listener?.remove()
    }
}

// MARK: - Preview

struct ChatDetailView_Previews: PreviewProvider {

    static var previews: some View {

        NavigationStack {

            ChatDetailView(
                chat: Chat(
                    id: "0PqoJ62fvxqslYoGcImQ",
                    participants: [
                        "BC3vz9m9FffzWrMlf6SKGPRptO92",
                        "szjx9ml8XhgFsEDBgEnH8L3DYPq1"
                    ],
                    itemId: "iyE1MNFzO5NTh418DIy8",
                    lastMessage: "Gib",
                    lastUpdated: Timestamp(
                        seconds: 1778448434,
                        nanoseconds: 286214000
                    )
                )
            )
        }
    }
}
