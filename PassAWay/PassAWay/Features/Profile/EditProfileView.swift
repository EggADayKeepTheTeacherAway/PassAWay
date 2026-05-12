//
//  EditProfileView.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    // The user data passed in from the ProfileView
    let user: User
    
    // Editable State
    @State private var name: String
    @State private var bio: String
    
    // Photo State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    // Initialize the state with the user's current info
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _bio = State(initialValue: user.bio)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PassBackground").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // MARK: - Change Profile Picture
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                if let selectedImage {
                                    selectedImage
                                        .resizable()
                                        .scaledToFill()
                                } else if !user.profileImageUrl.isEmpty, let url = URL(string: user.profileImageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color("PassPrimary").opacity(0.5))
                                }
                                
                                // Edit overlay
                                VStack {
                                    Spacer()
                                    Text("EDIT")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.6))
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        }
                        .onChange(of: selectedPhotoItem) { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                    selectedUIImage = uiImage
                                    selectedImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                        
                        // MARK: - Input Fields
                        VStack(alignment: .leading, spacing: 20) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                                TextField("Name", text: $name)
                                    .padding(.horizontal)
                                    .frame(height: 44)
                                    .background(Color("PassLightGreen"))
                                    .cornerRadius(10)
                            }
                            
                            // Bio Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                                TextEditor(text: $bio)
                                    .padding(8)
                                    .frame(height: 100)
                                    .scrollContentBackground(.hidden)
                                    .background(Color("PassLightGreen"))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("PassPrimary"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveChanges) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save").fontWeight(.bold)
                        }
                    }
                    .foregroundColor(Color("PassPrimary"))
                    .disabled(isSaving || name.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Save Logic
    private func saveChanges() {
        guard let uid = user.id else { return }
        isSaving = true
        errorMessage = ""
        
        Task {
            do {
                var newImageUrl = user.profileImageUrl
                
                // 1. Upload new image if they picked one
                if let uiImage = selectedUIImage, let imageData = uiImage.jpegData(compressionQuality: 0.5) {
                    let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
                    let _ = try await storageRef.putDataAsync(imageData)
                    newImageUrl = try await storageRef.downloadURL().absoluteString
                }
                
                // 2. Update Firestore
                let db = Firestore.firestore()
                try await db.collection("users").document(uid).updateData([
                    "name": name,
                    "bio": bio,
                    "profileImageUrl": newImageUrl
                ])
                
                // 3. Close the sheet
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save changes: \(error.localizedDescription)"
                    isSaving = false
                }
            }
        }
    }
}
