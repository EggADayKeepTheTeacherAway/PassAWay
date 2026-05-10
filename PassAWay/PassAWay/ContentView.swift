//
//  ContentView.swift
//  PassAWay
//
//  Created by Nunthapop on 9/5/2569 BE.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var currentUser: FirebaseAuth.User? = nil
    
    var body: some View {
        Group {
            if currentUser != nil {
                // If Firebase finds a user, show the main app
                MainTabView()
            } else {
                // If no user is found, show the login/register flow
                BootUpView()
            }
        }
        .onAppear {
            // As soon as the app opens, listen for changes in Auth state
            Auth.auth().addStateDidChangeListener { auth, user in
                self.currentUser = user
            }
        }
    }
}
