//
//  ProfileView.swift
//  PassAWay
//
//  Created by Nunthapop on 10/5/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PassBackground")
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading Profile...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("PassPrimary")))
                        .foregroundColor(Color("PassPrimary"))
                    
                } else if let user = viewModel.currentUser {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 20) {
                                
                                // MARK: Header Profile Row
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
                                            Text(user.name)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("PassPrimary"))
                                                .lineLimit(1)
                                            
                                            Text("@\(user.username)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("PassPrimary").opacity(0.7))
                                                .lineLimit(1)
                                        }
                                        .padding(.top, 12)
                                    }
                                    
                                    Spacer()
                                    NotificationBell()
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 15)
                                
                                // MARK: Bio Card
                                Text(user.bio)
                                    .font(.footnote)
                                    .foregroundColor(Color("PassPrimary").opacity(0.9))
                                    .lineSpacing(4)
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("PassLightGreen"))
                                    .cornerRadius(20)
                                    .padding(.horizontal, 25)
                                
                                // MARK: Stats Section
                                HStack(spacing: 15) {
                                    // Level Box
                                    VStack(spacing: 5) {
                                        Text("Level")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("PassPrimary"))
                                        
                                        Text("\(user.level)")
                                            .font(.system(size: 45, weight: .heavy))
                                            .foregroundColor(Color("PassPrimary"))
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color("PassLightGreen"))
                                    .cornerRadius(20)
                                    
                                    // XP and Listings Box
                                    VStack(spacing: 12) {
                                        let currentXP = CGFloat(user.xp ?? 0)
                                        let totalXP = CGFloat(user.calculatedMaxXp)
                                        
                                        HStack(spacing: 8) {
                                            GeometryReader { geometry in
                                                ZStack(alignment: .leading) {
                                                    Capsule()
                                                        .fill(Color.white)
                                                        .frame(height: 6)
                                                    
                                                    Capsule()
                                                        .fill(Color("PassPrimary"))
                                                        .frame(width: totalXP > 0 ? geometry.size.width * (currentXP / totalXP) : 0, height: 6)
                                                }
                                            }
                                            .frame(height: 6)
                                            
                                            Text("\(Int(currentXP))/\(Int(totalXP))")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(Color("PassPrimary"))
                                        }
                                        .padding(.top, 5)
                                        
                                        // Stats Rows
                                        VStack(spacing: 8) {
                                            HStack {
                                                Text("Listed")
                                                Spacer()
                                                Text("\(user.itemsListed)")
                                            }
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("PassPrimary"))
                                            
                                            HStack {
                                                Text("Given away")
                                                Spacer()
                                                Text("\(user.itemsGivenAway)")
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
                                
                                // MARK: My Posts Section
                                VStack(alignment: .center, spacing: 15) {
                                    Text("My Posts")
                                        .font(.title3)
                                        .fontWeight(.heavy)
                                        .foregroundColor(Color("PassPrimary"))
                                    
                                    
                                    // Now checking the actual array of fetched items!
                                    if viewModel.myItems.isEmpty {
                                        VStack(spacing: 12) {
                                            Image(systemName: "shippingbox")
                                                .font(.system(size: 40))
                                                .foregroundColor(Color("PassPrimary").opacity(0.5))
                                            
                                            Text("You haven't listed any items yet.")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color("PassPrimary").opacity(0.7))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 180)
                                        .background(Color("PassLightGreen").opacity(0.4))
                                        .cornerRadius(20)
                                        .padding(.horizontal, 25)
                                        
                                    } else {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 15) {
                                                ForEach(viewModel.myItems) { item in
                                                    NavigationLink(destination: PostDetailView(item: item)) {

                                                        GridItemCard(item: item)
                                                            .frame(width: 160) // 
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.horizontal, 25)
                                        }
                                    }
                                }
                                .padding(.top, 5)
                                
                                // MARK: Account Settings & Actions
                                VStack(spacing: 15) {
                                    ProfileMenuRow(icon: "pencil", title: "Edit Profile")
                                    ProfileMenuRow(icon: "gearshape", title: "Settings")
                                    
                                    Button(action: {
                                        viewModel.logOut()
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
                                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.red.opacity(0.3), lineWidth: 1))
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 10)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                } else {
                    // MARK: - Error State / Escape Hatch
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Failed to load profile.")
                            .font(.headline)
                            .foregroundColor(Color("PassPrimary"))
                        
                        Text("Your account data might be incomplete or missing from the database.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            viewModel.logOut()
                        }) {
                            Text("Force Log Out")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 45)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Helper Components
struct ProfileMenuRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        Button(action: { print("Tapped \(title)") }) {
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
