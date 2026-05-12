//
//  RequestSheet.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 12/5/26.
//


import SwiftUI

struct RequestSheet: View {
    @Binding var requestMessage: String
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Solid plain background
            Color("PassBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pushes the content to the middle of the sheet
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Request Message")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("PassPrimary"))
                            
                            Text("Tell the owner why you want this item.")
                                .font(.system(size: 15))
                                .foregroundColor(Color("PassPrimary"))
                        }
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.square.fill") 
                                .foregroundColor(Color("PassPrimary").opacity(0.4))
                                .font(.system(size: 26))
                        }
                    }
                    
                    // MARK: - Input Area
                    TextEditor(text: $requestMessage)
                        .font(.system(size: 16))
                        .foregroundColor(Color("PassPrimary"))
                        .padding(14)
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .background(Color("SearchBg"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("PassPrimary").opacity(0.2), lineWidth: 1)
                        )

                    // MARK: - Action Button
                    Button(action: onConfirm) {
                        Text("Send Request")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                requestMessage.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray.opacity(0.3)
                                : Color("PassPrimary")
                            )
                            .cornerRadius(8)
                    }
                    .disabled(requestMessage.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(24)
                .background(Color("PassBackground"))
                
                Spacer()
            }
        }
    }
}
