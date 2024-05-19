//
//  ListRowView.swift
//  Steps
//
//  Created by Aaron Wilson on 5/19/24.
//

import SwiftUI

struct ListRowView: View {
    let text: String
    var body: some View {
        HStack {
            Text(text)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.ultraThinMaterial)
        }    }
}

#Preview {
    ListRowView(text: "Your steps today are 11111")
}
