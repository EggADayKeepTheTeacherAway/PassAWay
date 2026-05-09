//
//  LoginView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color("PassPrimary"))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    
                    // Updated Header Text
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                        .padding(.bottom, 10)
                    
                    // Input Fields
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            TextField("Enter your username....", text: $username)
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            SecureField("Enter your Password....", text: $password)
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Submit Button & Footer
                    VStack(spacing: 15) {
                        NavigationLink(destination: Text("Main App View Goes Here")) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color("PassPrimary"))
                                .cornerRadius(10)
                        }
                        .padding(.top, 25)
                        
                        // Register Link
                        HStack(spacing: 5) {
                            Text("Don't have an account?")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            NavigationLink(destination: RegisterView()) {
                                Text("Sign Up")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PassPrimary"))
                                    .underline()
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
