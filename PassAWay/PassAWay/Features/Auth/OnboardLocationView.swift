//
//  OnboardLocationScreen.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI
import MapKit

struct OnboardLocationView: View {
    @Environment(\.dismiss) var dismiss
    
    // Default location: Kasetsart University Bangkhen
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 13.8473, longitude: 100.5696),
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )
    )
    
    @State private var selectedAddress: String = "Finding location..."
    
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color("PassPrimary"))
                    }
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
                
                // Selected Location Field
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
                
                // Interactive Map Area
                ZStack {
                    Map(position: $position)
                        .onMapCameraChange(frequency: .onEnd) { context in
                            fetchAddressFromCoordinates(coordinate: context.region.center)
                        }
                    
                    // Current Location Button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement GPS location snap
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
                    
                    // Center Pin
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
                
                // Guiding Text & Confirm Button
                VStack(spacing: 15) {
                    Text("Move the pin or search for the location")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    NavigationLink(destination: Text("Main Feed Goes Here")) {
                        Text("Confirm Location")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("PassPrimary"))
                            .cornerRadius(10)
                    }
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
    
    // MARK: - Helper Functions
    
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
}

#Preview {
    OnboardLocationView()
}
