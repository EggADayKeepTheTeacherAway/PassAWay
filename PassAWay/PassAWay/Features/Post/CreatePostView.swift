//
//  CreatePostView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Input State
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var pickupArea: String = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    
    @State private var category: String? = nil
    @State private var condition: String? = nil
    
    // MARK: - Custom Dropdown States
    @State private var isCategoryExpanded: Bool = false
    @State private var isConditionExpanded: Bool = false
    @State private var isShowingMapPicker: Bool = false
    
    // MARK: - Photo Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    // MARK: - Dropdown Options
    let categories = ["Food", "Clothes", "Electronics", "Books", "Household", "Other"]
    let conditions = ["New", "Like New", "Good", "Fair", "Poor"]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    BackButton()
                        .padding(.top, 10)
                        .buttonStyle(.plain)
                    
                    Text("Create New Post")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                    
                    // MARK: - Photo Upload Section
                    VStack(alignment: .center) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            if let selectedImage {
                                selectedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("PassPrimary").opacity(0.3), lineWidth: 2)
                                    )
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("PassLightGreen"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundColor(Color("PassPrimary").opacity(0.5))
                                        )
                                    
                                    VStack(spacing: 10) {
                                        Image(systemName: "photo.stack")
                                            .font(.system(size: 40))
                                        Text("Tap to add a photo")
                                            .font(.headline)
                                    }
                                    .foregroundColor(Color("PassPrimary"))
                                }
                            }
                        }
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
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Title Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            TextField("Enter item title (e.g., Red Bicycle)", text: $title)
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                        }

                        // Description Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            TextField("Describe features, condition, defects, size...", text: $description, axis: .vertical)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .frame(minHeight: 100, alignment: .top)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                        }
                        
                        // Custom Category Dropdown
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isCategoryExpanded.toggle()
                                        if isCategoryExpanded { isConditionExpanded = false }
                                    }
                                }) {
                                    HStack {
                                        Text(category ?? "Choose an item category...")
                                            .foregroundColor(category == nil ? .gray.opacity(0.8) : .primary)
                                        Spacer()
                                        Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(Color("PassPrimary"))
                                            .font(.caption)
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 44)
                                    .background(Color("PassLightGreen"))
                                }
                                
                                if isCategoryExpanded {
                                    VStack(spacing: 0) {
                                        ForEach(categories, id: \.self) { cat in
                                            Button(action: {
                                                category = cat
                                                withAnimation(.easeInOut(duration: 0.2)) { isCategoryExpanded = false }
                                            }) {
                                                Text(cat)
                                                    .foregroundColor(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.horizontal)
                                                    .frame(height: 44)
                                            }
                                            if cat != categories.last { Divider().padding(.horizontal) }
                                        }
                                    }
                                    .background(Color.white)
                                }
                            }
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: isCategoryExpanded ? 1 : 0))
                        }
                        
                        // Custom Condition Dropdown
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Condition")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isConditionExpanded.toggle()
                                        if isConditionExpanded { isCategoryExpanded = false }
                                    }
                                }) {
                                    HStack {
                                        Text(condition ?? "Choose the item's condition...")
                                            .foregroundColor(condition == nil ? .gray.opacity(0.8) : .primary)
                                        Spacer()
                                        Image(systemName: isConditionExpanded ? "chevron.up" : "chevron.down")
                                            .foregroundColor(Color("PassPrimary"))
                                            .font(.caption)
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 44)
                                    .background(Color("PassLightGreen"))
                                }
                                
                                if isConditionExpanded {
                                    VStack(spacing: 0) {
                                        ForEach(conditions, id: \.self) { cond in
                                            Button(action: {
                                                condition = cond
                                                withAnimation(.easeInOut(duration: 0.2)) { isConditionExpanded = false }
                                            }) {
                                                Text(cond)
                                                    .foregroundColor(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.horizontal)
                                                    .frame(height: 44)
                                            }
                                            if cond != conditions.last { Divider().padding(.horizontal) }
                                        }
                                    }
                                    .background(Color.white)
                                }
                            }
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: isConditionExpanded ? 1 : 0))
                        }
                        
                        // MARK: - NEW MAP TRIGGER
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pickup Area")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            Button(action: {
                                isShowingMapPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(Color("PassPrimary"))
                                    Text(pickupArea.isEmpty ? "Tap to select location on map" : pickupArea)
                                        .foregroundColor(pickupArea.isEmpty ? .gray.opacity(0.8) : .primary)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // MARK: - Submit Button & Footer
                    VStack(spacing: 15) {
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            guard let uiImage = selectedUIImage else { return }
                            
                            viewModel.uploadPost(
                                title: title,
                                description: description,
                                category: category ?? "",
                                condition: condition ?? "",
                                pickUpArea: pickupArea,
                                latitude: latitude ?? 0.0,   // Passes the new coordinates
                                longitude: longitude ?? 0.0, // Passes the new coordinates
                                image: uiImage
                            ) {
                                dismiss()
                            }
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Post Item")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("PassPrimary"))
                            .cornerRadius(10)
                        }
                        // Added location variables to the disable validation
                        .disabled(title.isEmpty || pickupArea.isEmpty || category == nil || condition == nil || selectedUIImage == nil || latitude == nil || longitude == nil || viewModel.isLoading)
                        .opacity((title.isEmpty || pickupArea.isEmpty || category == nil || condition == nil || selectedUIImage == nil || latitude == nil || longitude == nil) ? 0.5 : 1.0)
                        .padding(.top, 15)
                    }
                    
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        // Present the Map Sheet
        .sheet(isPresented: $isShowingMapPicker) {
            PostLocationPickerView(selectedAddress: $pickupArea, latitude: $latitude, longitude: $longitude)
        }
    }
}

#Preview {
    CreatePostView()
}
