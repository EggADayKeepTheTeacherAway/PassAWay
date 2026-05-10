//
//  NotificationView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

// MARK: - Mock Data Models
struct NotificationItem: Identifiable {
    let id = UUID()
    let userName: String
    let action: String
    let itemName: String
    let timeAgo: String
    let isUnread: Bool
    let avatarImage: String
}

struct NotificationSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [NotificationItem]
}

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    
    // Change to 'true' to see the Empty State, 'false' for the Populated State
    @State private var showEmptyState: Bool = false
    
    // MARK: - Mock Data
    let sections = [
        NotificationSection(title: "New", items: [
            NotificationItem(userName: "Mansanod", action: "made a request to claim your", itemName: "White T-shirt.", timeAgo: "4m ago", isUnread: true, avatarImage: "person.crop.circle.fill"),
            NotificationItem(userName: "Perter", action: "made a request to claim your", itemName: "White T-shirt.", timeAgo: "4m ago", isUnread: true, avatarImage: "person.crop.circle.fill")
        ]),
        NotificationSection(title: "Today", items: [
            NotificationItem(userName: "Sarawut", action: "made a request to claim your", itemName: "White T-shirt.", timeAgo: "2h ago", isUnread: false, avatarImage: "person.crop.circle.fill")
        ]),
        NotificationSection(title: "Yesterday", items: [
            NotificationItem(userName: "Nathan", action: "made a request to claim your", itemName: "White T-shirt.", timeAgo: "1d ago", isUnread: false, avatarImage: "person.crop.circle.fill")
        ])
    ]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Custom Header
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("Notifications")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Spacer()
                }
                .foregroundColor(Color("PassPrimary"))
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // MARK: - Content Area
                if showEmptyState {
                    // EMPTY STATE
                    VStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color("PassLightGreen"))
                                .frame(width: 180, height: 180)
                            
                            Image(systemName: "bell.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color("PassPrimary"))
                        }
                        .padding(.bottom, 20)
                        
                        Text("You're all caught up")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(Color("PassPrimary"))
                        
                        Spacer()
                    }
                } else {
                    // OPULATED STATE
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(sections) { section in
                                VStack(alignment: .leading, spacing: 15) {
                                    
                                    // Section Title (New, Today, Yesterday)
                                    Text(section.title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                    
                                    // Notification Items in this section
                                    ForEach(section.items) { item in
                                        NotificationRow(item: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
                
                // MARK: - Bottom Tab Bar
                TabBarView(selectedTab: .constant(0))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Individual Notification Row View
struct NotificationRow: View {
    var item: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            
            // Avatar
            Image(systemName: item.avatarImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .foregroundColor(Color("PassPrimary").opacity(0.8))
                .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.1), radius: 3, y: 2))
            
            // Text Content & Divider
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                                    
                    // Main Notification Text (FIXED: Kept strictly as 'Text' types)
                    Text("\(Text(item.userName).fontWeight(.semibold)) \(Text("\(item.action) “\(item.itemName)”").foregroundStyle(Color("PassPrimary").opacity(0.9)))")
                        .foregroundColor(Color("PassPrimary"))
                                    
                    Spacer()
                                    
                    // Unread Dot Indicator
                    if item.isUnread {
                        Circle()
                        .fill(Color("PassPrimary"))
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    }
                }
                .font(.subheadline)
                .lineSpacing(4)
                
                // Time Ago
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Custom thin divider aligned with text
                Divider()
                    .padding(.top, 5)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NotificationView()
}
