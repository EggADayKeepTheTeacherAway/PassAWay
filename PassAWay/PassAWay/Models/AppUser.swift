//
//  UserModel.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable {
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
    
    // @ServerTimestamp tells Firebase to automatically stamp this with the exact time it hits the database
    @ServerTimestamp var createdAt: Date?
}

struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var address_string: String
}
