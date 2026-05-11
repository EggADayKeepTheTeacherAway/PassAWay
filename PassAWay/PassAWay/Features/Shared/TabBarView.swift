//
//  TabBarView.swift
//  PassAWay
//
//  Created by SHARK 🦈 on 10/5/26.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selected: Int
    var onAddTapped: () -> Void 


    var tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("square.grid.2x2.fill", "Browse"),
        ("bubble.left.fill", "Chat"),
        ("person.fill", "Profile"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Spacer()

                if i == 2 {

                    Button(action: {
                        onAddTapped() // TRIGGER THE ACTION HERE
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color("PassPrimary"))
                            .clipShape(Circle())
                            .shadow(color: Color("PassPrimary").opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                    .offset(y: -12)
                    Spacer()
                }

                Button(action: { selectedTab = i }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: 18))
                            .foregroundColor(selectedTab == i ? Color("PassPrimary") : Color("PassPrimary").opacity(0.35))
                        Text(tabs[i].label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == i ? Color("PassPrimary") : Color("PassPrimary").opacity(0.35))
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -4)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
