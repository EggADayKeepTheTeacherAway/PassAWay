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
        let result = currentUserId != message.senderId
        print("🔍 isGiver: \(result)")
        print("   currentUserId: \(currentUserId)")
        print("   message.senderId: \(message.senderId)")
        print("   giverId: \(giverId)")
        
        print("Message: ", message)
        print("ItemStatus: ", itemStatus)
        return result
    }
    
    @State private var itemStatus: String = ""
    @State private var itemPhoto: String = ""
    
    private var requestStatus: String? {
        message.status // this is String?
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: itemPhoto)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color("PassLightGreen")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            
            Text(message.text)
                    .font(.system(size: 13))
                    .foregroundColor(Color("PassPrimary").opacity(0.75))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

            if isGiver && itemStatus == "Available" {
                HStack(spacing: 0) {
                    Button(action: onNo) {
                        Text("No")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.black)
                    }
                    Button(action: onGive) {
                        Text("Give")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.black)
                    }
                }
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("PassPrimary").opacity(0.15)))
            }
            else if requestStatus == "Accepted" {
                HStack {
                    Text("Request approved")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
            }
            else if requestStatus == "Rejected" {
                HStack {
                    Text("Request rejected")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
            }
        }
        .background(Color("PassLightGreen").opacity(0.3))
        .cornerRadius(12)
        .frame(maxWidth: 260, alignment: .leading)
        .task {
            await fetchItem()
        }
    }

    func fetchItem() async {
        do {
            let doc = try await Firestore.firestore()
                .collection("items")
                .document(itemId)
                .getDocument()
            let item = try doc.data(as: Item.self)
            print("Item", item)
            itemPhoto = item.photoUrl
            
        } catch {
            print("❌ Failed to fetch item photo: \(error)")
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
