//
//  RegisterView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - Input State
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color("PassBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header Navigation
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
                    
                    // Header Text
                    Text("Create New Account")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                    
                    // Avatar Picker
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color("PassLightGreen"))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color("PassPrimary"))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: - Input Fields
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("PassPrimary"))
                            
                            TextField("Enter your name....", text: $name)
                                .padding(.horizontal)
                                .frame(height: 44)
                                .background(Color("PassLightGreen"))
                                .cornerRadius(10)
                            
                            // Inline Validation Warning
                            if !name.isEmpty && !isNameValid {
                                Text("Name cannot contain numbers.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
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
                            
                            // Inline Validation Warning
                            if !email.isEmpty && !isEmailValid {
                                Text("Please enter a valid email address.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
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
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            
                            // Inline Validation Warning
                            if !username.isEmpty && !isUsernameValid {
                                Text("Username must be at least 3 characters and have no spaces.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
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
                            
                            // Inline Validation Warning
                            if !password.isEmpty && !isPasswordValid {
                                Text("Password must be at least 6 characters.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // MARK: - Submit Button & Footer
                    VStack(spacing: 15) {
                        NavigationLink(destination: OnboardLocationView(
                            name: name,
                            email: email,
                            username: username,
                            password: password
                        )) {
                            Text("Continue to Location")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color("PassPrimary"))
                                .cornerRadius(10)
                        }
                        .padding(.top, 25)
                        .disabled(!isFormValid) // Disables the button if form is invalid
                        .opacity(isFormValid ? 1.0 : 0.5) // Fades the button to look disabled
                        
                        // Sign In Link
                        HStack(spacing: 5) {
                            Text("Already have an account?")
                                .font(.footnote)
                                .fontWeight(.semibold)
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
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30) // Extra padding for scrolling
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Form Validation Logic
    
    private var isNameValid: Bool {
        // Name must not be empty AND must not contain any decimal digits
        !name.isEmpty && name.rangeOfCharacter(from: .decimalDigits) == nil
    }
    
    private var isEmailValid: Bool {
        // Basic Regex pattern to ensure it looks like an email (something@something.com)
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private var isUsernameValid: Bool {
        // Must be at least 3 characters and contain no spaces
        username.count >= 3 && !username.contains(" ")
    }
    
    private var isPasswordValid: Bool {
        // Firebase Auth requires a minimum of 6 characters for passwords
        password.count >= 6
    }
    
    private var isFormValid: Bool {
        // The final check: ALL fields must be valid for this to return true
        isNameValid && isEmailValid && isUsernameValid && isPasswordValid
    }
}

// MARK: - Gesture Extension
extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}

#Preview {
    RegisterView()
}
