//
//  NotificationViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var unreadItems: [NotificationUIItem] = []
    @Published var readItems: [NotificationUIItem] = []
    @Published var isLoading = true
    
    private let db = Firestore.firestore()
    
    init() {
        fetchNotifications()
    }
    
    func fetchNotifications() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Listen to the top-level collection where you are the receiver
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: currentUserId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                let fetchedNotifs = documents.compactMap { try? $0.data(as: AppNotification.self) }
                self.processNotifications(fetchedNotifs)
            }
    }
    
    // This looks up the sender's name for every notification
    private func processNotifications(_ notifications: [AppNotification]) {
        Task {
            var tempUnread: [NotificationUIItem] = []
            var tempRead: [NotificationUIItem] = []
            
            for notif in notifications {
                // Fetch the sender's profile to get their name
                var senderName = "Someone"
                do {
                    let userDoc = try await db.collection("users").document(notif.senderId).getDocument()
                    if let user = try? userDoc.data(as: User.self) {
                        senderName = user.name
                    }
                } catch {
                    print("Failed to fetch sender name: \(error)")
                }
                
                let uiItem = NotificationUIItem(id: notif.id ?? UUID().uuidString, notification: notif, senderName: senderName)
                
                // Group them by Read / Unread
                if notif.isRead {
                    tempRead.append(uiItem)
                } else {
                    tempUnread.append(uiItem)
                }
            }
            
            self.unreadItems = tempUnread
            self.readItems = tempRead
            self.isLoading = false
        }
    }
    
    // Call this when the user opens the notification screen to mark them all as read!
    func markAllAsRead() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: currentUserId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    doc.reference.updateData(["isRead": true])
                }
            }
    }
}
