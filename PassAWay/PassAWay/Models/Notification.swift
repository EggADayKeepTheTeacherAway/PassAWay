//
//  Notification.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//

import Foundation
import FirebaseFirestore

struct AppNotification: Codable, Identifiable {
    @DocumentID var id: String?
    var receiverId: String
    var senderId: String
    var type: String
    var body: String
    var isRead: Bool
    @ServerTimestamp var createdAt: Date?
}

struct NotificationUIItem: Identifiable {
    let id: String
    let notification: AppNotification
    let senderName: String
}
