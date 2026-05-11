//
//  BootUpView.swift
//  
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI

struct BootUpView: View {
    var body: some View {
        
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Graphic Placeholder
                Circle()
                    .fill(Color("PassLightGreen"))
                    .frame(width: 250, height: 250)
                    .overlay(
                        Text("Image Placeholder")
                            .foregroundColor(Color("PassPrimary"))
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
        }
        
    }
}

#Preview {
    NavigationStack {
        BootUpView()
    }
}
