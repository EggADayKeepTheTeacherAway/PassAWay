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

struct OnboardLocationView: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties passed from RegisterView
    var name: String
    var email: String
    var username: String
    var password: String
    
    // MARK: - Map State
    // Default location initialized to Kasetsart University Bangkhen
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
    @State private var navigateToMainFeed = false
    
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
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
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
                                    Text("Current Location")
                                        .fontWeight(.bold)
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
                    
                    // Error Display
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
                    
                    // Final Submission Button
                    Button(action: {
                        createFirebaseAccount(coordinate: currentCoordinate)
                    }) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
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
        .navigationDestination(isPresented: $navigateToMainFeed) {
            Text("MAIN FEED!")
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Location Services
    
    /// Converts latitude and longitude into a readable street or city address
    private func fetchAddressFromCoordinates(coordinate: CLLocationCoordinate2D) {
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            guard let request = MKReverseGeocodingRequest(location: location) else {
                await MainActor.run { selectedAddress = "Invalid Location" }
                return
            }
            
            do {
                let mapItems = try await request.mapItems
                
                if let mapItem = mapItems.first {
                    let name = mapItem.name ?? ""
                    let city = mapItem.addressRepresentations?.cityName ?? mapItem.addressRepresentations?.regionName ?? ""
                    
                    await MainActor.run {
                        if !name.isEmpty && !city.isEmpty && name != city {
                            selectedAddress = "\(name), \(city)"
                        } else if !name.isEmpty {
                            selectedAddress = name
                        } else if !city.isEmpty {
                            selectedAddress = city
                        } else {
                            selectedAddress = "Unknown Area"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    selectedAddress = "Locating..."
                }
            }
        }
    }
    
    // MARK: - Authentication & Database
    
    /// Creates the Firebase Auth credential and saves the public User object to Firestore
    private func createFirebaseAccount(coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = ""
        
        // 1. Initialize Firebase Auth user
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                isLoading = false
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            // 2. Construct the Firestore User document
            let userLocation = LocationData(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                address_string: selectedAddress
            )
            
            let newUser = AppUser(
                id: uid,
                user_id: uid,
                username: username,
                email: email,
                name: name,
                profileImageUrl: "",
                bio: "New to PassAWay!",
                location: userLocation,
                level: 1,
                itemsListed: 0,
                itemsGivenAway: 0
            )
            
            // 3. Write data to the users collection
            let db = Firestore.firestore()
            do {
                try db.collection("users").document(uid).setData(from: newUser) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        isLoading = false
                        return
                    }
                    
                    isLoading = false
                    navigateToMainFeed = true
                }
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardLocationView(
        name: "Test User",
        email: "test@kasetsart.ac.th",
        username: "tester123",
        password: "password123"
    )
}
