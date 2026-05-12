//
//  UserAvatarView.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//


import SwiftUI
import FirebaseFirestore

struct UserAvatarView: View {
    let userId: String
    let size: CGFloat
    
    @State private var imageUrl: String? = nil
    
    var body: some View {
        ZStack {
            if let imageUrl = imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                // Shows their actual uploaded picture
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                        .tint(Color("PassPrimary"))
                }
            } else {
                // Shows the default green circle if they don't have a picture
                Circle()
                    .fill(Color("PassPrimary"))
                
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear {
            fetchUserImage()
        }
    }
    
    // Secretly fetches just the image URL from the users collection
    private func fetchUserImage() {
        Task {
            do {
                let db = Firestore.firestore()
                let document = try await db.collection("users").document(userId).getDocument()
                
                if let urlString = document.data()?["profileImageUrl"] as? String {
                    await MainActor.run {
                        self.imageUrl = urlString
                    }
                }
            } catch {
                print("Failed to load avatar for \(userId): \(error.localizedDescription)")
            }
        }
    }
}