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
    // This publishes changes to the View whenever the data updates
    @Published var currentUser: User?
    @Published var isLoading: Bool = true
    
    private let db = Firestore.firestore()
    
    init() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() { // FIXED: Was spelled 'featchCurrentUser'
            // 1. Get the current logged-in user's UID
            guard let uid = Auth.auth().currentUser?.uid else {
                print("No user is currently logged in.")
                self.isLoading = false
                return
            }
            
            // 2. Use a Task to run async code safely on the MainActor
            Task {
                do {
                    // Fetch the document using modern async/await
                    let document = try await db.collection("users").document(uid).getDocument()
                    
                    // 3. Decode the document into your User model
                    if document.exists {
                        self.currentUser = try document.data(as: User.self)
                    } else {
                        print("User document does not exist.")
                    }
                } catch {
                    print("Error fetching or decoding user: \(error.localizedDescription)")
                }
                
                // Turn off loading whether it succeeded or failed
                self.isLoading = false
            }
    }
    
    // Function for your log out button
    func logOut() {
        do {
            // NEW: Tell the app we want to go straight to login
            UserDefaults.standard.set(true, forKey: "wantsDirectLogin")
            
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
