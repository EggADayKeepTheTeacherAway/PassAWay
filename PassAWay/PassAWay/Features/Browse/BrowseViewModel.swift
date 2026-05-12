//
//  BrowseViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = true
    
    private let db = Firestore.firestore()
    
    init() {
        fetchItems()
    }
    
    func fetchItems() {
        isLoading = true
        db.collection("items")
            .whereField("status", isEqualTo: "Available")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                self.isLoading = false
                guard let documents = snapshot?.documents else { return }
                
                self.items = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
            }
    }
}
