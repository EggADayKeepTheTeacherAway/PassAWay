//
//  HomeView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI
import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSearch = false
    @State private var centeredItemId: String? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("PassBackground")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hi, \(viewModel.currentUser?.name ?? "there")")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color("PassPrimary"))
                                    .lineLimit(1)
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
                            VStack {
                                Text("Uh oh, something went wrong. Please try again later.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .onAppear { print("Error:  \(error)") }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

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
                                                .onChange(of: geo.frame(in: .global).midX) { midX in
                                                    let screenMid = UIScreen.main.bounds.width / 2
                                                    if abs(midX - screenMid) < 80 {
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
                    viewModel.fetchCurrentUser() // ADDED to refreshable
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.listenToItems()
            viewModel.fetchCurrentUser() 
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.colorScheme, .light)
    }
}

// MARK: - ViewModel

@MainActor
private final class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currentUser: User?

    private let db = Firestore.firestore()
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let document = try await db.collection("users").document(uid).getDocument()
                if document.exists {
                    self.currentUser = try document.data(as: User.self)
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }

    func listenToItems() {
        isLoading = true
        db.collection("items")
            .whereField("status", isEqualTo: "Available")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.items = []
                    self.isLoading = false
                    return
                }

                var newItems: [Item] = []
                for doc in documents {
                    do {
                        let item = try doc.data(as: Item.self)
                        newItems.append(item)
                        print("✅ Decoded: \(item.title)")
                    } catch {
                        print("❌ Failed to decode \(doc.documentID): \(error)")
                    }
                }
                self.items = newItems
                self.isLoading = false
            }
    }
}
