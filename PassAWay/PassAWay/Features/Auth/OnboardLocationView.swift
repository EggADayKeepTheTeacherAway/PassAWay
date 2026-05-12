//
//  OnboardLocationView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct OnboardLocationView: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties passed from RegisterView
    var name: String
    var email: String
    var username: String
    var password: String
    var profileImage: UIImage
    
    // MARK: - Map State
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 13.8473, longitude: 100.5696),
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
    )
    
    @State private var selectedAddress: String = "Finding location..."
    @State private var currentCoordinate = CLLocationCoordinate2D(latitude: 13.8473, longitude: 100.5696)
    
    // MARK: - Authentication State
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Header Navigation
                VStack(alignment: .leading, spacing: 8) {
                    BackButton()
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    
                    Text("Where are you located?")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                    
                    Text("Find items and people near you.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                
                // Address Search Field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("PassPrimary"))
                    
                    TextField("Search address...", text: $selectedAddress)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 25)
                .padding(.bottom, 15)
                
                // Interactive Map Component
                ZStack {
                    Map(position: $position)
                        .onMapCameraChange(frequency: .onEnd) { context in
                            currentCoordinate = context.region.center
                            fetchAddressFromCoordinates(coordinate: context.region.center)
                        }
                    
                    // Current Location Request Button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement CoreLocation manager logic
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "location.fill")
                                    Text("Current Location").fontWeight(.bold)
                                }
                                .font(.footnote)
                                .foregroundColor(Color("PassPrimary"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                            }
                        }
                        .padding(15)
                        Spacer()
                    }
                    
                    // Center Target Pin
                    VStack(spacing: 0) {
                        Image(systemName: "mappin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 40)
                            .foregroundColor(.red)
                        
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 10, height: 5)
                            .offset(y: -2)
                    }
                    .offset(y: -20)
                }
                .clipShape(Rectangle())
                
                // Confirmation Footer
                VStack(spacing: 15) {
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Move the pin or search for the location")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Button(action: {
                        createFirebaseAccount(coordinate: currentCoordinate)
                    }) {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Confirm Location")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("PassPrimary"))
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                .background(Color("PassBackground"))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchAddressFromCoordinates(coordinate: CLLocationCoordinate2D(latitude: 13.8473, longitude: 100.5696))
        }
    }
    
    // MARK: - Location Services
    private func fetchAddressFromCoordinates(coordinate: CLLocationCoordinate2D) {
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            
            do {
                let mapItems = try await request.mapItems
                if let mapItem = mapItems.first {
                    let name = mapItem.name ?? ""
                    let city = mapItem.addressRepresentations?.cityName ?? mapItem.addressRepresentations?.regionName ?? ""
                    
                    await MainActor.run {
                        if !name.isEmpty && !city.isEmpty && name != city {
                            selectedAddress = "\(name), \(city)"
                        } else if !name.isEmpty { selectedAddress = name
                        } else if !city.isEmpty { selectedAddress = city
                        } else { selectedAddress = "Unknown Area" }
                    }
                }
            } catch {
                await MainActor.run { selectedAddress = "Locating..." }
            }
        }
    }
    
    // MARK: - Authentication, Image Upload & Database
    private func createFirebaseAccount(coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // 1. Create the Auth User
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = authResult.user.uid
                
                // 2. Upload the Profile Image
                var uploadedImageUrl = ""
                
                if let imageData = profileImage.jpegData(compressionQuality: 0.5) {
                    let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
                    // Upload the data
                    let _ = try await storageRef.putDataAsync(imageData)
                    // Retrieve the public URL
                    let downloadURL = try await storageRef.downloadURL()
                    uploadedImageUrl = downloadURL.absoluteString
                }
                
                // 3. Construct the Firestore User document
                let userLocation = LocationData(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    address_string: selectedAddress
                )
                
                let newUser = User(
                    id: uid,
                    user_id: uid,
                    username: username,
                    email: email,
                    name: name,
                    profileImageUrl: uploadedImageUrl, 
                    bio: "New to PassAWay!",
                    location: userLocation,
                    level: 1,
                    itemsListed: 0,
                    itemsGivenAway: 0
                )
                
                // 4. Save to Firestore
                try db.collection("users").document(uid).setData(from: newUser)
                
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    private let db = Firestore.firestore()
}

// MARK: - Preview
#Preview {
    OnboardLocationView(
        name: "Test User",
        email: "test@kasetsart.ac.th",
        username: "tester123",
        password: "password123",
        profileImage: UIImage()
    )
}
