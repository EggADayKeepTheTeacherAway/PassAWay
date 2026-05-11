//
//  PostLocationPickerView.swift
//  PassAWay
//
//  Created by Nunthapop on 11/5/2569 BE.
//

import SwiftUI
import MapKit

struct PostLocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    // Bindings to send data back to CreatePostView
    @Binding var selectedAddress: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    
    // Default map location centered on Rangsit, Pathum Thani
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.9883, longitude: 100.6175),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var isFetchingAddress = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. The Interactive Map
                Map(coordinateRegion: $region, interactionModes: .all)
                    .ignoresSafeArea()
                
                // 2. The Center Pin (Stays in the middle while the user drags the map)
                VStack {
                    Spacer()
                    Image(systemName: "mappin")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.bottom, 40)
                        Spacer()
                }
                
                // 3. Confirm Button
                VStack {
                    Spacer()
                    Button(action: {
                        confirmLocation()
                    }) {
                        ZStack {
                            if isFetchingAddress {
                                ProgressView().tint(.white)
                            } else {
                                Text("Select This Location")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("PassPrimary"))
                        .cornerRadius(10)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                    .disabled(isFetchingAddress)
                }
            }
            .navigationTitle("Choose Pickup Area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color("PassPrimary"))
                }
            }
        }
    }
    
    // MARK: - Geocoding Logic
    private func confirmLocation() {
        isFetchingAddress = true
        let center = region.center
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isFetchingAddress = false
            
            if let place = placemarks?.first {
                // Combine available address details into a readable string
                let street = place.thoroughfare ?? place.name ?? ""
                let district = place.subLocality ?? place.locality ?? ""
                let province = place.administrativeArea ?? ""
                
                let combinedAddress = [street, district, province]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                
                // Update bindings and dismiss
                selectedAddress = combinedAddress.isEmpty ? "Selected Location" : combinedAddress
                latitude = center.latitude
                longitude = center.longitude
                
                dismiss()
            } else {
                // Fallback if the geocoder fails
                selectedAddress = "Unknown Location"
                latitude = center.latitude
                longitude = center.longitude
                dismiss()
            }
        }
    }
}
