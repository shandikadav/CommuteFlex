//
//  StatCardView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftUI

struct StatCardView: View {
    let iconName: String
    let title: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        StatCardView(iconName: "number", title: "Total Trips", value: "42")
        StatCardView(
            iconName: "tram.fill",
            title: "Most Used",
            value: "MRT Jakarta",
            subtitle: "18 trips"
        )
    }
}
