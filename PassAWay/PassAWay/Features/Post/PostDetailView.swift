//
//  PostDetailView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


import SwiftUI
import FirebaseFirestore


struct PostDetailView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
    
    @State private var showRequestSheet = false
    @State private var requestMessage = ""
    @State private var createdChat: Chat? = nil
    @State private var navigateToChat = false
    
    // TODO: replace with Auth.auth().currentUser?.uid
    let currentUserId = "BC3vz9m9FffzWrMlf6SKGPRptO92"

    func sendRequest() {
        let db = Firestore.firestore()
        let chatRef = db.collection("chats").document()

        let chatData: [String: Any] = [
            "participants": [currentUserId, item.giverId],
            "itemId": item.id,
            "lastMessage": requestMessage,
            "lastUpdated": Timestamp()
        ]

        chatRef.setData(chatData) { error in
            if let error {
                print("❌ Failed to create chat: \(error)")
                return
            }

            // send first message
            let messageData: [String: Any] = [
                "senderId": currentUserId,
                "text": requestMessage,
                "timestamp": Timestamp()
            ]

            chatRef.collection("messages").addDocument(data: messageData) { error in
                if let error {
                    print("❌ Failed to send message: \(error)")
                    return
                }

                let chat = Chat(
                    id: chatRef.documentID,
                    participants: [currentUserId, item.giverId],
                    itemId: item.id.uuidString,
                    lastMessage: requestMessage,
                    lastUpdated: Timestamp()
                )

                DispatchQueue.main.async {
                    self.createdChat = chat
                    self.navigateToChat = true
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("PassBackground")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Hero Image
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color("PassLightGreen"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)

                        // Back button
                        BackButton()
                        .padding(.top, 52)
                        .padding(.leading, 20)
                    }

                    // MARK: Content Card
                    VStack(alignment: .leading, spacing: 0) {

                        // Title + poster row
                        HStack(alignment: .top) {
                            Text(item.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("PassPrimary"))
                            Spacer()
                            // Poster avatar
                            Circle()
                                .fill(Color("PassPrimary"))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                        .padding(.bottom, 6)

                        Text(item.postedBy)
                            .font(.system(size: 12))
                            .foregroundColor(Color("PassPrimary").opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        Divider()
                            .background(Color("PassPrimary").opacity(0.1))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        // Description
                        Text(item.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("PassPrimary").opacity(0.75))
                            .lineSpacing(5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                        // MARK: Meta chips
                        VStack(spacing: 12) {
                            MetaRow(label: "Category", value: item.category)
                            MetaRow(label: "Condition", value: item.condition)
                            MetaRow(label: "Pickup Area", value: item.pickupArea)
                            MetaRow(label: "Posted", value: item.timeAgo)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // space for bottom button
                    }
                    .background(Color("PassBackground"))
                }
            }
            .ignoresSafeArea(edges: .top)

            // MARK: Request Button (placeholder, no action yet)
            VStack(spacing: 0) {
                Divider().background(Color("PassPrimary").opacity(0.08))
                Button(action: {
                    showRequestSheet = true
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
        .sheet(isPresented: $showRequestSheet) {
            RequestSheet(
                requestMessage: $requestMessage,
                onConfirm: {
                    sendRequest()
                    showRequestSheet = false
                }
            )
            .presentationDetents([.medium])
        }
        .navigationDestination(isPresented: $navigateToChat) {
            if let chat = createdChat {
                ChatDetailView(chat: chat)
            }
        }

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
            title: "White T-Shirt",
            description: "Lorem ipsum is simply dummy text of the printing and typesetting industry. Been the industry's standard dummy text ever since the 1500s.",
            category: "Clothes",
            condition: "Brand New",
            pickupArea: "Phaya Thai",
            imageName: nil,
            postedBy: "Mansanod Hot",
            timeAgo: "2m ago",
            giverId: "BC3vz9m9FffzWrMlf6SKGPRptO92"
        ))
    }
}
