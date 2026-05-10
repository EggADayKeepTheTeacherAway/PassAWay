//
//  RequestSheet.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 11/5/26.
//

import SwiftUI


struct RequestSheet: View {
    @Binding var requestMessage: String
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Request Message")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("PassPrimary"))

            Text("Tell the owner why you want this item.")
                .font(.system(size: 13))
                .foregroundColor(Color("PassPrimary").opacity(0.5))

            TextEditor(text: $requestMessage)
                .font(.system(size: 14))
                .foregroundColor(Color("PassPrimary"))
                .padding(12)
                .frame(height: 120)
                .background(Color("SearchBg"))
                .cornerRadius(12)

            Button(action: onConfirm) {
                Text("Send Request")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(requestMessage.isEmpty ? Color("PassPrimary").opacity(0.4) : Color("PassPrimary"))
                    .cornerRadius(14)
            }
            .disabled(requestMessage.isEmpty)

            Spacer()
        }
        .padding(24)
    }
}
