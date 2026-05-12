//
//  NotificationBell.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//
import SwiftUI

struct NotificationBell: View {
    @State private var hasUnread = true

    var body: some View {
        NavigationLink(destination: NotificationView()) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("PassPrimary"))

                if hasUnread {
                    Circle()
                        .fill(Color("PassAccent"))
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
            }
            .frame(width: 40, height: 40)
            .background(Color("SearchBg"))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            hasUnread = false
        })
    }
}

#Preview {
    NotificationBell()
}
