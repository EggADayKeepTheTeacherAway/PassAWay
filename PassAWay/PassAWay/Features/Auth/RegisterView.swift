//
//  RegisterView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct RegisterView: View {
    // MARK: - Input State
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    // MARK: - Photo Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    // MARK: - Navigation & Error State
    @State private var isCheckingEmail = false
    @State private var navigateToLocation = false
    @State private var serverErrorMessage = ""
    
    @Environment(\.dismiss) var dismiss
    
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
                    
                    Text("Create New Account")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("PassPrimary"))
                    
                    // MARK: - Avatar Picker
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                if let selectedImage {
                                    selectedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                                } else {
                                    Circle()
                                        .fill(Color("PassLightGreen"))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(Color("PassPrimary"))
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItem) { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                    selectedUIImage = uiImage
                                    selectedImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: - Input Fields
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                            TextField("Enter your name....", text: $name)
                                .padding(.horizontal).frame(height: 44).background(Color("PassLightGreen")).cornerRadius(10)
                            if !name.isEmpty && !isNameValid { Text("Name cannot contain numbers.").font(.caption).foregroundColor(.red) }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                            TextField("Enter your email....", text: $email)
                                .padding(.horizontal).frame(height: 44).background(Color("PassLightGreen")).cornerRadius(10)
                                .keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                            if !email.isEmpty && !isEmailValid { Text("Please enter a valid email address.").font(.caption).foregroundColor(.red) }
                        }
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                            TextField("Enter your username....", text: $username)
                                .padding(.horizontal).frame(height: 44).background(Color("PassLightGreen")).cornerRadius(10)
                                .textInputAutocapitalization(.never).autocorrectionDisabled()
                            if !username.isEmpty && !isUsernameValid { Text("Username must be at least 3 characters, no spaces.").font(.caption).foregroundColor(.red) }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password").font(.subheadline).fontWeight(.semibold).foregroundColor(Color("PassPrimary"))
                            SecureField("Enter your Password....", text: $password)
                                .padding(.horizontal).frame(height: 44).background(Color("PassLightGreen")).cornerRadius(10)
                            if !password.isEmpty && !isPasswordValid { Text("Password must be at least 6 characters.").font(.caption).foregroundColor(.red) }
                        }
                    }
                    
                    // MARK: - Submit Button & Footer
                    VStack(spacing: 15) {
                        
                        // Show server error if the email is taken
                        if !serverErrorMessage.isEmpty {
                            Text(serverErrorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Smart Button that checks Firebase before moving on
                        Button(action: {
                            verifyEmailAndProceed()
                        }) {
                            ZStack {
                                if isCheckingEmail {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Continue to Location")
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
                        .disabled(!isFormValid || isCheckingEmail)
                        .opacity(isFormValid ? 1.0 : 0.5)
                        
                        // The actual invisible navigation router
                        .navigationDestination(isPresented: $navigateToLocation) {
                            OnboardLocationView(
                                name: name,
                                email: email,
                                username: username,
                                password: password,
                                profileImage: selectedUIImage ?? UIImage() // Passes empty image if none selected
                            )
                        }
                        
                        // Sign In Link
                        HStack(spacing: 5) {
                            Text("Already have an account?").font(.footnote).fontWeight(.semibold).foregroundColor(.gray)
                            NavigationLink(destination: LoginView()) {
                                Text("Sign In").font(.footnote).fontWeight(.bold).foregroundColor(Color("PassPrimary")).underline()
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Verification Logic
    private func verifyEmailAndProceed() {
        isCheckingEmail = true
        serverErrorMessage = ""
        
        // Pings Firebase to see if this email is already registered
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            isCheckingEmail = false
            
            if let error = error {
                serverErrorMessage = error.localizedDescription
                return
            }
            
            // If 'methods' is not nil, it means an account exists
            if let methods = methods, !methods.isEmpty {
                serverErrorMessage = "This email is already registered. Please sign in."
            } else {
                navigateToLocation = true
            }
        }
    }
    
    // MARK: - Form Validation Logic
    private var isNameValid: Bool { !name.isEmpty && name.rangeOfCharacter(from: .decimalDigits) == nil }
    private var isEmailValid: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    private var isUsernameValid: Bool { username.count >= 3 && !username.contains(" ") }
    private var isPasswordValid: Bool { password.count >= 6 }
    private var isFormValid: Bool { isNameValid && isEmailValid && isUsernameValid && isPasswordValid }
}

#Preview {
    RegisterView()
}
