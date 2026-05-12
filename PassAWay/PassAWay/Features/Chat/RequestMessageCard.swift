//
//  RequestMessageCard.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 11/5/26.
//

import SwiftUI
import FirebaseFirestore

struct RequestMessageCard: View {
    let message: Message
    let itemId: String
    let giverId: String
    let currentUserId: String
    let onGive: () -> Void
    let onNo: () -> Void

    var isGiver: Bool {
        return currentUserId != message.senderId
    }
    
    @State private var itemStatus: String = ""
    @State private var itemPhoto: String = ""
    @State private var fetchedItem: Item? = nil 
    
    @State private var requestStatus: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Item Image
            AsyncImage(url: URL(string: itemPhoto)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.white.opacity(0.5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()
            
            // Message & See More Link
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(Color("PassPrimary").opacity(0.9))
                    .lineSpacing(4)
                
                if let item = fetchedItem {
                    NavigationLink(destination: PostDetailView(item: item)) {
                        Text("See item details")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color("PassPrimary"))
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // Action Buttons
            if isGiver && itemStatus == "Available" && requestStatus == nil {
                HStack(spacing: 12) {
                                
                    // NO Button (Thinner)
                    Button(action: {
                        onNo()
                        requestStatus = "Rejected"
                    }) {
                        Text("No")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("PassPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                                
                    // GIVE Button
                    Button(action: {
                        onGive()
                        requestStatus = "Accepted"
                    }) {
                        Text("Give")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color("PassPrimary"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                            
            } else if requestStatus == "Accepted" {
                HStack {
                    Text("Request approved")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.6))
                        .clipShape(Capsule())
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                            
            } else if requestStatus == "Rejected" {
                HStack {
                    Text("Request rejected")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.6))
                        .clipShape(Capsule())
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(Color("PassLightGreen"))
        .cornerRadius(16)
        .frame(maxWidth: 260, alignment: .leading)
        .task {
            await fetchItem()
            requestStatus = message.status
        }
    }

    func fetchItem() async {
        do {
            let doc = try await Firestore.firestore()
                .collection("items")
                .document(itemId)
                .getDocument()
            let item = try doc.data(as: Item.self)
            
            // Save everything we need
            self.fetchedItem = item
            self.itemPhoto = item.photoUrl
            self.itemStatus = item.status
            
        } catch {
            print("❌ Failed to fetch item: \(error)")
        }
    }
}


struct RequestMessageCard_Previews: PreviewProvider {
    static var previews: some View {
        RequestMessageCard(
            message: Message(
                id: "msg1",
                senderId: "BC3vz9m9FffzWrMlf6SKGPRptO92",
                text: "I want this!",
                timestamp: Timestamp(seconds: 1778448434, nanoseconds: 0),
                type: "request",
//                status: "Accepted"
            ),
            itemId: "iyE1MNFzO5NTh418DIy8",
            giverId: "szjx9ml8XhgFsEDBgEnH8L3DYPq1",
            currentUserId: "szjx9ml8XhgFsEDBgEnH8L3DYPq1",
            onGive: { print("Give tapped") },
            onNo: { print("No tapped") }
        )
        .padding()
        
    }
}
