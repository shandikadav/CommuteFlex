//
//  TripRowView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftUI

struct TripRowView: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 12) {
            // Transport icon
            Image(systemName: trip.transportType.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(transportColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                // Stations
                HStack(spacing: 4) {
                    Text(trip.departureStation)
                        .fontWeight(.medium)

                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(trip.arrivalStation)
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .lineLimit(1)

                // Transport type + corridor
                HStack(spacing: 6) {
                    Text(trip.transportType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let corridor = trip.corridorCode, !corridor.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(corridor)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Time
            Text(trip.date, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tripAccessibilityLabel)
    }

    private var transportColor: Color {
        switch trip.transportType.tintColor {
        case "red": .red
        case "blue": .blue
        case "orange": .orange
        case "purple": .purple
        case "green": .green
        default: .gray
        }
    }

    private var tripAccessibilityLabel: String {
        var label =
            "\(trip.transportType.displayName) from \(trip.departureStation) to \(trip.arrivalStation)"
        if let corridor = trip.corridorCode, !corridor.isEmpty {
            label += ", corridor \(corridor)"
        }
        return label
    }
}
