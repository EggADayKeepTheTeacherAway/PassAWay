//
//  HomeView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI
import FirebaseFirestore
import Combine


struct HomeView: View {
    @Binding var selectedTab: Int
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSearch = false
    @State private var centeredItemId: String? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("PassBackground")
                    .ignoresSafeArea()
                GeometryReader { screenGeo in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // MARK: Header
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Hi, Rattanan")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color("PassPrimary"))
                                }
                                Spacer()
                                NotificationBell()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            Spacer().frame(height: 20)
                            
                            // MARK: Recently Added
                            HStack {
                                
                                Text("Recently Added")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color("PassPrimary"))
                                Spacer()
                                Button("See all") {
                                    // Navigate to browse
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("PassPrimary").opacity(0.6))
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 14)
                            
                            // MARK: Item Grid
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 60)
                                    .tint(Color("PassPrimary"))
                                
                            } else if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 40)
                                
                            } else if viewModel.items.isEmpty {
                                Text("No items available right now.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("PassPrimary").opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 60)
                                
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(viewModel.items) { item in
                                            GeometryReader { geo in
                                                HomeItemCard(item: item)
                                                    .onChange(of: geo.frame(in: .global).midX) {
                                                        let screenMid = UIScreen.main.bounds.width / 2
                                                        if abs(geo.frame(in: .global).midX - screenMid) < 80 {
                                                            centeredItemId = item.id
                                                        }
                                                    }
                                            }
                                            .frame(width: 260, height: 320)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                // Text below scroll
                                if let centered = viewModel.items.first(where: { $0.id == centeredItemId }) ?? viewModel.items.first {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(centered.title)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color("PassPrimary"))
                                        
                                        Text(centered.description)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("PassPrimary").opacity(0.6))
                                            .lineLimit(2)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                    .animation(.easeInOut, value: centeredItemId)
                                }
                            }
                            
                            Spacer().frame(height: 100)
                        }
                    }.refreshable {
                        viewModel.listenToItems()
                    }
                }

                // MARK: Tab Bar
                TabBarView(selectedTab: .constant(0))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.listenToItems()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
    }
}


// MARK: - ViewModel

@MainActor
private final class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func listenToItems() {
        isLoading = true
        db.collection("items")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                if let error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                self.items = []  // reset before each update
                for doc in snapshot?.documents ?? [] {
                    do {
                        let item = try doc.data(as: Item.self)
                        self.items.append(item)
                        print("✅ Decoded: \(item.title)")
                    } catch {
                        print("❌ Failed to decode \(doc.documentID): \(error)")
                    }
                }
                self.isLoading = false
            }
    }
}

