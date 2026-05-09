//
//  BackButton.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI


struct BackButton: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
    }
}
