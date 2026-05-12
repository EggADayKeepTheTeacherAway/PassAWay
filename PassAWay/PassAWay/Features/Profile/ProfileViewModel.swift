//
//  ProfileViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//


import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = true
    @Published var myItems: [Item] = [] 
    
    private let db = Firestore.firestore()
    
    init() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            self.isLoading = false
            return
        }
            
        db.collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
                
            guard let document = documentSnapshot, document.exists else {
                print("User document does not exist.")
                self.isLoading = false
                return
            }
                
            do {
                let user = try document.data(as: User.self)
                self.currentUser = user
                
                // 1. Fetch their items
                self.fetchMyItems(uid: uid)
                    
                // 2. TRIGGER THE LEVEL UP LOGIC!
                self.checkLevelUp(user: user)
                    
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
            }
                
            self.isLoading = false
        }
    }
    
    func fetchMyItems(uid: String) {
        db.collection("items")
            .whereField("giverId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let fetchedItems = documents.compactMap { try? $0.data(as: Item.self) }
                self.myItems = fetchedItems.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
            }
    }
    
    func checkLevelUp(user: User) {
        let currentXp = user.xp ?? 0
        let maxXp = user.calculatedMaxXp
            
        if currentXp >= maxXp {
            let newLevel = user.level + 1
            let leftoverXp = currentXp - maxXp
            
            // Update Firestore
            guard let uid = user.id else { return }
            
            db.collection("users").document(uid).updateData([
                "level": newLevel,
                "xp": leftoverXp
            ]) { error in
                if let error = error {
                    print("❌ Error leveling up: \(error.localizedDescription)")
                } else {
                    print("✅ Leveled up to \(newLevel) with \(leftoverXp) leftover XP")
                }
            }
        }
    }
    
    func logOut() {
        do {
            UserDefaults.standard.set(true, forKey: "wantsDirectLogin")
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
}
