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
        
        Task {
            do {
                let document = try await db.collection("users").document(uid).getDocument()
                
                if document.exists {
                    self.currentUser = try document.data(as: User.self)
                    
                    self.fetchMyItems(uid: uid)
                    
                } else {
                    print("User document does not exist.")
                }
            } catch {
                print("Error fetching or decoding user: \(error.localizedDescription)")
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
    
    func logOut() {
        do {
            UserDefaults.standard.set(true, forKey: "wantsDirectLogin")
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
