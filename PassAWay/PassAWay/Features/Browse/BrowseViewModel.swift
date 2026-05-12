//
//  BrowseViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var allItems: [Item] = []
    @Published var isLoading: Bool = true
    
    // MARK: - Filter & Sort States
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var selectedSort: String = "Recently Added"
    
    @Published var currentUserLocation: CLLocation? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        fetchCurrentUserLocation() // Fetch the user's real location first!
        fetchItems()
    }
    
    // MARK: - The Magic Filter Function
    var filteredItems: [Item] {
        var result = allItems
        
        // 1. Apply Search Filter
        if !searchText.isEmpty {
            result = result.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 2. Apply Category Filter
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // 3. Apply Sorting
        if selectedSort == "Near Me" {
            if let userLoc = currentUserLocation {
                        
                // Filter out anything further than 20 kilometers (20,000 meters)
                result = result.filter { item in
                    let itemLoc = CLLocation(latitude: item.latitude, longitude: item.longitude)
                    return itemLoc.distance(from: userLoc) <= 20_000 // Only keep items within 20km
                }
                            
                // Sort the remaining nearby items (closest first)
                result.sort { item1, item2 in
                    let loc1 = CLLocation(latitude: item1.latitude, longitude: item1.longitude)
                    let loc2 = CLLocation(latitude: item2.latitude, longitude: item2.longitude)
                    return loc1.distance(from: userLoc) < loc2.distance(from: userLoc)
                }
            }
        } else {
            // "Recently Added" or "Everywhere" (Sort by newest date)
            result.sort { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
        }
        
        return result
    }
    
    // MARK: - Firebase Fetches
    func fetchItems() {
        db.collection("items")
            .whereField("status", isEqualTo: "Available")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.allItems = documents.compactMap { try? $0.data(as: Item.self) }
                self.isLoading = false
            }
    }
    
    func fetchCurrentUserLocation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let document = try await db.collection("users").document(uid).getDocument()
                if let user = try? document.data(as: User.self) {
                    // Convert your custom LocationData into an Apple CLLocation
                    self.currentUserLocation = CLLocation(
                        latitude: user.location.latitude,
                        longitude: user.location.longitude
                    )
                }
            } catch {
                print("Failed to fetch user location for Near Me sorting: \(error)")
            }
        }
    }
}
