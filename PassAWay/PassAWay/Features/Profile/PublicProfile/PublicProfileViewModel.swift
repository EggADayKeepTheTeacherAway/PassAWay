
//
//  PublicProfileViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//


import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var items: [Item] = []
    @Published var isLoading: Bool = true
    
    let targetUserId: String
    private let db = Firestore.firestore()
    
    init(targetUserId: String) {
        self.targetUserId = targetUserId
        fetchUser()
        fetchItems()
    }
    
    func fetchUser() {
        Task {
            do {
                let document = try await db.collection("users").document(targetUserId).getDocument()
                if document.exists {
                    self.user = try document.data(as: User.self)
                }
            } catch {
                print("Error fetching public profile: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func fetchItems() {
        db.collection("items")
            .whereField("giverId", isEqualTo: targetUserId)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let fetchedItems = documents.compactMap { try? $0.data(as: Item.self) }
                self.items = fetchedItems.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
            }
    }
}
