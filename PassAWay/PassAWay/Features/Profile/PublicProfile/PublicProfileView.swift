//
//  PublicProfileView.swift
//  PassAWay
//
//  Created by Nunthapop on 12/5/2569 BE.
//

import SwiftUI

struct PublicProfileView: View {
    @StateObject private var viewModel: PublicProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: PublicProfileViewModel(targetUserId: userId))
    }
    
    var body: some View {
        ZStack {
            Color("PassBackground").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color("PassPrimary"))
            } else if let user = viewModel.user {
                VStack(spacing: 0) {
                    
                    // Custom Back Button Header
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .font(.headline)
                            .foregroundColor(Color("PassPrimary"))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            // MARK: Header Row
                            HStack(alignment: .center, spacing: 15) {
                                UserAvatarView(userId: user.id ?? "", size: 80)
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PassPrimary"))
                                        .lineLimit(2)
                                    
                                    Text("@\(user.username)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("PassPrimary").opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 10)
                            
                            // MARK: Bio Card
                            if !user.bio.isEmpty {
                                Text(user.bio)
                                    .font(.footnote)
                                    .foregroundColor(Color("PassPrimary").opacity(0.9))
                                    .lineSpacing(4)
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("PassLightGreen"))
                                    .cornerRadius(20)
                                    .padding(.horizontal, 25)
                            }
                            
                            // MARK: Stats Section
                            HStack(spacing: 15) {
                                VStack(spacing: 5) {
                                    Text("Level").font(.headline).fontWeight(.bold).foregroundColor(Color("PassPrimary"))
                                    Text("\(user.level)").font(.system(size: 45, weight: .heavy)).foregroundColor(Color("PassPrimary"))
                                }
                                .frame(width: 100, height: 100)
                                .background(Color("PassLightGreen")).cornerRadius(20)
                                
                                VStack(spacing: 12) {
                                    let currentXP = CGFloat(user.xp ?? 0)
                                    let totalXP = CGFloat(user.calculatedMaxXp)
                                    
                                    HStack(spacing: 8) {
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Capsule().fill(Color.white).frame(height: 6)
                                                Capsule().fill(Color("PassPrimary")).frame(width: totalXP > 0 ? geometry.size.width * (currentXP / totalXP) : 0, height: 6)
                                            }
                                        }.frame(height: 6)
                                        Text("\(Int(currentXP))/\(Int(totalXP))").font(.system(size: 10, weight: .semibold)).foregroundColor(Color("PassPrimary"))
                                    }.padding(.top, 5)
                                    
                                    VStack(spacing: 8) {
                                        HStack { Text("Listed"); Spacer(); Text("\(user.itemsListed)") }
                                            .font(.subheadline).fontWeight(.bold).foregroundColor(Color("PassPrimary"))
                                        HStack { Text("Given away"); Spacer(); Text("\(user.itemsGivenAway)") }
                                            .font(.subheadline).fontWeight(.bold).foregroundColor(Color("PassPrimary"))
                                    }
                                }
                                .padding(.horizontal, 15).padding(.vertical, 15).frame(height: 100).background(Color("PassLightGreen")).cornerRadius(20)
                            }
                            .padding(.horizontal, 25)
                            
                            // MARK: User's Posts Section
                            VStack(alignment: .center, spacing: 15) {
                                // Dynamic Title!
                                Text("\(user.name)'s Posts")
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color("PassPrimary"))
                                
                                if viewModel.items.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "shippingbox").font(.system(size: 40)).foregroundColor(Color("PassPrimary").opacity(0.5))
                                        Text("No active listings.")
                                            .font(.subheadline).fontWeight(.medium).foregroundColor(Color("PassPrimary").opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity).frame(height: 180).background(Color("PassLightGreen").opacity(0.4)).cornerRadius(20).padding(.horizontal, 25)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(viewModel.items) { item in
                                                NavigationLink(destination: PostDetailView(item: item)) {
                                                    GridItemCard(item: item).frame(width: 160)
                                                }.buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 25)
                                    }
                                }
                            }
                            .padding(.top, 5)
                            .padding(.bottom, 40)
                        }
                    }
                }
            } else {
                Text("User not found.").foregroundColor(.gray)
            }
        }
        .navigationBarHidden(true)
    }
}
