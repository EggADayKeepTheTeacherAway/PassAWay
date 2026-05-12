import SwiftUI
import MapKit
import CoreLocation
import Combine


struct PostLocationPickerView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var locationManager = LocationManager()
    
    @Binding var selectedAddress: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.9883, longitude: 100.6175),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var geocodeTask: Task<Void, Never>? = nil

    @State private var isFetchingAddress = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, interactionModes: .all)
                    .ignoresSafeArea()
                    .onChange(of: region.center.latitude) {
                        geocodeTask?.cancel()
                        geocodeTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                            guard !Task.isCancelled else { return }
                            await reverseGeocode()
                        }
                    }

                // Center Pin
                VStack {
                    Spacer()
                    Image(systemName: "mappin")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.bottom, 40)
                    Spacer()
                }

                // Search + Results overlay
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("PassPrimary").opacity(0.5))
                        TextField("Search location...", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(Color("PassPrimary"))
                            .onSubmit { Task { await searchLocation() } }
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color("PassPrimary").opacity(0.4))
                            }
                        }
                        if isSearching {
                            ProgressView().tint(Color("PassPrimary"))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Results dropdown
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { item in
                                Button(action: { selectResult(item) }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(Color("PassPrimary"))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name ?? "")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Color("PassPrimary"))
                                                .lineLimit(1)
                                            Text(item.placemark.title ?? "")
                                                .font(.system(size: 11))
                                                .foregroundColor(Color("PassPrimary").opacity(0.5))
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                }
                                Divider().padding(.leading, 44)
                            }
                        }
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }
                    

                    Spacer()

                    // Confirm Button
                    Button(action: { confirmLocation() }) {
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

    // MARK: - Search

    func searchLocation() async {
        guard !searchText.isEmpty else { return }
        isSearching = true
        searchResults = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region

        do {
            let response = try await MKLocalSearch(request: request).start()
            searchResults = Array(response.mapItems.prefix(5))
        } catch {
            print("❌ Search error: \(error)")
        }

        isSearching = false
    }

    func selectResult(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        withAnimation {
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        searchText = item.name ?? ""
        searchResults = []
    }

    // MARK: - Geocoding

    private func confirmLocation() {
        isFetchingAddress = true
        let center = region.center
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(CLLocation(latitude: center.latitude, longitude: center.longitude)) { placemarks, _ in
            isFetchingAddress = false
            let place = placemarks?.first
            let street = place?.thoroughfare ?? place?.name ?? ""
            let district = place?.subLocality ?? place?.locality ?? ""
            let province = place?.administrativeArea ?? ""

            let combinedAddress = [street, district, province]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")

            selectedAddress = combinedAddress.isEmpty ? "Selected Location" : combinedAddress
            latitude = center.latitude
            longitude = center.longitude
            dismiss()
        }
    }
    
    func reverseGeocode() async {
        let center = region.center
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: center.latitude, longitude: center.longitude)
            )
            if let place = placemarks.first {
                let street = place.thoroughfare ?? place.name ?? ""
                let district = place.subLocality ?? place.locality ?? ""
                let province = place.administrativeArea ?? ""
                let address = [street, district, province]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                searchText = address.isEmpty ? "Selected Location" : address
                searchResults = []
            }
        } catch {
            print("❌ Reverse geocode error: \(error)")
        }
    }
}


@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.lastLocation = locations.first
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
    }
}
