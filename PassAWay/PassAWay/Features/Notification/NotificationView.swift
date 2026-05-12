//
//  NotificationView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Custom Header
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
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
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Color("PassPrimary"))
                    Spacer()
                } else if viewModel.unreadItems.isEmpty && viewModel.readItems.isEmpty {
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
                    // POPULATED STATE
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            
                            // UNREAD SECTION
                            if !viewModel.unreadItems.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("New")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                    
                                    ForEach(viewModel.unreadItems) { item in
                                        NotificationRow(item: item)
                                    }
                                }
                            }
                            
                            // READ SECTION
                            if !viewModel.readItems.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Earlier")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                    
                                    ForEach(viewModel.readItems) { item in
                                        NotificationRow(item: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            // When they leave the screen, mark everything as read!
            viewModel.markAllAsRead()
        }
    }
}

// MARK: - Individual Notification Row View
struct NotificationRow: View {
    var item: NotificationUIItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            
            // SMART AVATAR: Pulls their real profile picture based on the senderId!
            UserAvatarView(userId: item.notification.senderId, size: 50)
                .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            
            // Text Content & Divider
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    
                    // Dynamic Message Builder based on Notification Type
                    let actionText = item.notification.type == "request_received" ? "made a request to claim your" : "sent an update regarding"
                    
                    Text("\(Text(item.senderName).fontWeight(.semibold)) \(Text("\(actionText) “\(item.notification.body)”").foregroundStyle(Color("PassPrimary").opacity(0.9)))")
                        .foregroundColor(Color("PassPrimary"))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Unread Dot Indicator
                    if !item.notification.isRead {
                        Circle()
                            .fill(Color("PassPrimary"))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                    }
                }
                .font(.subheadline)
                .lineSpacing(4)
                
                // Formats the Date into a readable string
                if let date = item.notification.createdAt {
                    Text(date.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.top, 5)
            }
        }
    }
}

#Preview {
    NotificationView()
}
