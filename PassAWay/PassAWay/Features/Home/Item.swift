//
//  Item.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI


struct Item: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let condition: String
    let pickupArea: String
    let imageName: String? // system symbol or nil for placeholder
    let postedBy: String
    let timeAgo: String
}
