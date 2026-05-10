//
//  ProfileView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    
    // MARK: - Mock User Data
    @State private var name: String = "Nunthapop Nganiam"
    @State private var username: String = "Nunthapop"
    @State private var bio: String = "Hi, everyone i am a software and knowledge engineering student from KU. I love coding :)"
    
    @State private var level: Int = 6
    @State private var xp: CGFloat = 67
    @State private var totalXp: CGFloat = 100
    
    @State private var itemsListed: Int = 4
    @State private var itemsGiven: Int = 1
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Header Profile Row
                        HStack(alignment: .top) {
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 86, height: 86)
                                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                                    
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .foregroundColor(Color("PassPrimary").opacity(0.8))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                        .lineLimit(1)
                                    
                                    Text("@\(username)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("PassPrimary").opacity(0.7))
                                        .lineLimit(1)
                                }
                                .padding(.top, 12)
                            }
                            
                            Spacer()
                            
                            // Notification Bell on the far right
                            NotificationBell()
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                        
                        // MARK: - Bio Card (Standalone)
                        Text(bio)
                            .font(.footnote)
                            .foregroundColor(Color("PassPrimary").opacity(0.9))
                            .lineSpacing(4)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("PassLightGreen"))
                            .cornerRadius(20)
                            .padding(.horizontal, 25)
                        
                        // MARK: - Stats Section
                        HStack(spacing: 15) {
                            // Level Box
                            VStack(spacing: 5) {
                                Text("Level")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PassPrimary"))
                                
                                Text("\(level)")
                                    .font(.system(size: 45, weight: .heavy))
                                    .foregroundColor(Color("PassPrimary"))
                            }
                            .frame(width: 100, height: 100)
                            .background(Color("PassLightGreen"))
                            .cornerRadius(20)
                            
                            // XP and Listings Box
                            VStack(spacing: 12) {
                                // Custom Progress Bar
                                HStack(spacing: 8) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.white)
                                                .frame(height: 6)
                                            
                                            Capsule()
                                                .fill(Color("PassPrimary"))
                                                .frame(width: geometry.size.width * (xp / totalXp), height: 6)
                                        }
                                    }
                                    .frame(height: 6)
                                    
                                    Text("\(Int(xp))/\(Int(totalXp))")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(Color("PassPrimary"))
                                }
                                .padding(.top, 5)
                                
                                // Stats Rows
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Listed")
                                        Spacer()
                                        Text("\(itemsListed)")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PassPrimary"))
                                    
                                    HStack {
                                        Text("Given away")
                                        Spacer()
                                        Text("\(itemsGiven)")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PassPrimary"))
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                            .frame(height: 100)
                            .background(Color("PassLightGreen"))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal, 25)
                        
                        // MARK: - My Posts Carousel
                        VStack(alignment: .center, spacing: 15) {
                            Text("My Posts")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .foregroundColor(Color("PassPrimary"))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<4) { index in
                                        ZStack(alignment: .bottomLeading) {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color("PassLightGreen"))
                                                .frame(width: 220, height: 250)
                                            
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .foregroundColor(Color("PassPrimary"))
                                                .padding(15)
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                        .padding(.top, 5)
                        
                        // MARK: - Account Settings & Actions
                        VStack(spacing: 15) {
                            ProfileMenuRow(icon: "pencil", title: "Edit Profile")
                            ProfileMenuRow(icon: "gearshape", title: "Settings")
                            
                            Button(action: {
                                print("Logging out...")
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    Text("Log Out")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
                
                // MARK: - Bottom Tab Bar
                TabBarView(selectedTab: .constant(0))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Helper Components
struct ProfileMenuRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("PassPrimary"))
                    .frame(width: 30)
                
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color("PassLightGreen").opacity(0.5))
            .cornerRadius(15)
        }
    }
}

#Preview {
    ProfileView()
}
