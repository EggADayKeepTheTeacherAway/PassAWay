//
//  RegisterView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
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
                    BackButton()
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
                    
                    // Input Fields
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
                        NavigationLink(destination: OnboardLocationView()) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color("PassPrimary"))
                                .cornerRadius(10)
                        }
                        .padding(.top, 25)
                        
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
            }
        }
        .navigationBarHidden(true)
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}


#Preview {
    RegisterView()
}
