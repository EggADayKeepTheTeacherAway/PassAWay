//
//  LoginView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Input State
    @State private var email: String = ""
    @State private var password: String = ""
    
    // MARK: - Authentication State
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    @State private var navigateToMainFeed = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    BackButton()
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                        .padding(.bottom, 10)
                    
                    // Input Fields
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            TextField("Enter your email....", text: $email)
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
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
                        
                        // Error Display
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Firebase Login Button
                        Button(action: {
                            loginUser()
                        }) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("PassPrimary"))
                            .cornerRadius(10)
                        }
                        .padding(.top, 15)
                        .disabled(isLoading) // Prevent double-clicking
                        
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
        .navigationDestination(isPresented: $navigateToMainFeed) {
            Text("MAIN FEED!")
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Authentication Methods
    
    private func loginUser() {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // Call Firebase to sign the user in
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            // Success! Trigger the navigation to the main feed
            navigateToMainFeed = true
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
