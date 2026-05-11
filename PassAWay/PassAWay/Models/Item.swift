//
//  Item.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import Foundation
import FirebaseFirestore


struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var giverId: String
    var photoUrl: String
    var title: String
    var description: String
    var category: String
    var condition: String
    var pickUpArea: String
    var latitude: Double  
    var longitude: Double
    var status: String
    var claimedBy: String?
    var createdAt: Timestamp
}
