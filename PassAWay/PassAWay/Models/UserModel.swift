//
//  UserModel.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import Foundation
import FirebaseFirestore

struct User: Codable {
    // @DocumentID automatically grabs the Firebase document name (which will be their Auth UID)
    @DocumentID var id: String?
    
    var user_id: String
    var username: String
    var email: String
    var name: String
    var profileImageUrl: String
    var bio: String
    var location: LocationData
    var level: Int
    var itemsListed: Int
    var itemsGivenAway: Int
    var xp: Int?
    // @ServerTimestamp tells Firebase to automatically stamp this with the exact time it hits the database
    @ServerTimestamp var createdAt: Date?
    
    var calculatedMaxXp: Int {
        // Base 100 XP, multiplied by 1.25 for every level they gain
        let baseXP = 100.0
        let multiplier = pow(1.25, Double(level - 1))
        return Int(baseXP * multiplier)
    }
}

struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var address_string: String
}
