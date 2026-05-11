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

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var itemId: String
    var lastMessage: String
    var lastUpdated: Timestamp
}


struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Timestamp
    var type: String?
}
