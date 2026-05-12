//
//  BootUpView.swift
//  
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI

struct BootUpView: View {
    @AppStorage("wantsDirectLogin") private var wantsDirectLogin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PassBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Constructed Smiley Face Visual
                    Circle()
                        .fill(Color("PassLightGreen"))
                        .frame(width: 250, height: 250)
                        .overlay(
                            ZStack {
                                // Face Container
                                Circle()
                                    .fill(Color("PassLightGreen"))
                                    .frame(width: 250, height: 250)
                                
                                // Eyes (FIXED: Removed the stray 0000)
                                HStack(spacing: 60) {
                                    Circle()
                                        .fill(Color("PassPrimary"))
                                        .frame(width: 20, height: 20)
                                        
                                    Circle()
                                        .fill(Color("PassPrimary"))
                                        .frame(width: 20, height: 20)
                                }
                                .offset(y: -40) // Move eyes up slightly
                                
                                // Mouth
                                Circle()
                                    .trim(from: 0.25, to: 0.75) // Trim to a semicircle shape
                                    .stroke(Color("PassPrimary"), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)) // Thick, rounded line
                                    .frame(width: 130) // Size of the arc
                                    .rotationEffect(.degrees(180)) // Rotate to make it a smile
                                    .offset(y: 35) // Move smile down
                            }
                        )
                    
                    // Text Content
                    VStack(spacing: 12) {
                        Text("Sharing is Caring :)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PassPrimary"))
                        
                        Text("Give unused items a second life. \nReduce waste and help the community.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Bottom Buttons
                    VStack(spacing: 20) {
                        // Register Navigation
                        NavigationLink(destination: RegisterView()) {
                            Text("Get Start !")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("PassPrimary"))
                                .cornerRadius(12)
                                .padding(.horizontal, 30)
                        }
                        
                        // Login Navigation
                        HStack(spacing: 5) {
                            Text("Already have an account?")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            NavigationLink(destination: LoginView()) {
                                Text("Sign In")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PassPrimary"))
                                    .underline()
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .navigationDestination(isPresented: $wantsDirectLogin) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    BootUpView()
}
