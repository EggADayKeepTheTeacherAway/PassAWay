//
//  CreatePostViewModel.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    func uploadPost(title: String, description: String, category: String, condition: String, pickUpArea: String, latitude: Double, longitude: Double, image: UIImage, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "You must be logged in to post."
            self.isLoading = false
            return
        }
        
        Task {
            do {
                // 1. Upload Image to Firebase Storage
                let imageRef = Storage.storage().reference().child("item_images/\(UUID().uuidString).jpg")
                guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
                
                let _ = try await imageRef.putDataAsync(imageData)
                let imageUrl = try await imageRef.downloadURL()
                
                // 2. Create the Item document
                let newItem = Item(
                    id: UUID().uuidString,
                    giverId: uid,
                    photoUrl: imageUrl.absoluteString,
                    title: title,
                    description: description,
                    category: category,
                    condition: condition,
                    pickUpArea: pickUpArea,
                    latitude: latitude,
                    longitude: longitude,
                    status: "Available",
                    createdAt: Timestamp()
                )
                
                // 3. Save to Firestore
                try db.collection("items").document(newItem.id ?? UUID().uuidString).setData(from: newItem)
                
                // 4. Reward the User! (Increment listings and add 5 XP)
                try await db.collection("users").document(uid).updateData([
                    "itemsListed": FieldValue.increment(Int64(1)),
                    "xp": FieldValue.increment(Int64(5)) 
                ])
                
                isLoading = false
                onSuccess() // Trigger the UI to dismiss
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
