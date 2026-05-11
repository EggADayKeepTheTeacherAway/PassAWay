//
//  Chat.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//


//
//  Chat.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var participants: [String]
    var itemId: String
    var lastMessage: String
    var lastUpdated: Timestamp
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
}


struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Timestamp
    var type: String?
    var status: String?
}
