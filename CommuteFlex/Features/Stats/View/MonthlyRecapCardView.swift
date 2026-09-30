//
//  MonthlyRecapCardView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftUI

struct MonthlyRecapCardView: View {
    let periodTitle: String
    let totalTrips: Int
    let mostUsedTransport: (type: TransportType, count: Int)?
    let topStation: (station: String, count: Int)?
    let topCorridor: (corridor: String, count: Int)?
    let totalDistance: String
    let totalSpending: String
    let transportBreakdown: [(type: TransportType, count: Int)]
    let hasDistance: Bool
    let hasSpending: Bool

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header

            headerSection

            // MARK: - Stats Content

            VStack(spacing: 20) {
                // Total trips highlight
                totalTripsSection

                Divider()
                    .overlay(Color.white.opacity(0.2))

                // Key stats grid
                keyStatsGrid

                // Transport breakdown
                if !transportBreakdown.isEmpty {
                    Divider()
                        .overlay(Color.white.opacity(0.2))

                    transportBreakdownSection
                }

                // Totals
                if hasDistance || hasSpending {
                    Divider()
                        .overlay(Color.white.opacity(0.2))

                    totalsSection
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)

            Spacer(minLength: 16)

            // MARK: - Footer

            footerSection
        }
        .frame(width: 390, height: 693) // 9:16 ratio, scaled for phone
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "tram.fill")
                    .font(.title3)

                Text("CommuteFlex")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)

            Text(periodTitle)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
        }
        .padding(.top, 32)
        .padding(.bottom, 16)
    }

    // MARK: - Total Trips

    private var totalTripsSection: some View {
        VStack(spacing: 4) {
            Text("\(totalTrips)")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("TRIPS LOGGED")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.7))
                .tracking(2)
        }
    }

    // MARK: - Key Stats Grid

    private var keyStatsGrid: some View {
        VStack(spacing: 16) {
            if let transport = mostUsedTransport {
                recapStatRow(
                    icon: transport.type.iconName,
                    label: "Most Used",
                    value: transport.type.displayName,
                    detail: "\(transport.count) trips"
                )
            }

            if let station = topStation {
                recapStatRow(
                    icon: "mappin.and.ellipse",
                    label: "Top Station",
                    value: station.station,
                    detail: "\(station.count) visits"
                )
            }

            if let corridor = topCorridor {
                recapStatRow(
                    icon: "arrow.triangle.branch",
                    label: "Top Corridor",
                    value: corridor.corridor,
                    detail: "\(corridor.count) trips"
                )
            }
        }
    }

    // MARK: - Transport Breakdown

    private var transportBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BREAKDOWN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.7))
                .tracking(1.5)

            ForEach(transportBreakdown.prefix(4), id: \.type) { item in
                HStack(spacing: 10) {
                    Image(systemName: item.type.iconName)
                        .font(.caption)
                        .frame(width: 20)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(item.type.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    Spacer()

                    // Progress bar
                    GeometryReader { geometry in
                        let ratio = totalTrips > 0
                            ? CGFloat(item.count) / CGFloat(totalTrips)
                            : 0

                        RoundedRectangle(cornerRadius: 3)
                            .fill(.white.opacity(0.15))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.white.opacity(0.6))
                                    .frame(width: geometry.size.width * ratio)
                            }
                    }
                    .frame(width: 80, height: 6)

                    Text("\(item.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
    }

    // MARK: - Totals

    private var totalsSection: some View {
        HStack(spacing: 24) {
            if hasDistance {
                VStack(spacing: 4) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(totalDistance)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Distance")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }

            if hasDistance && hasSpending {
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 50)
            }

            if hasSpending {
                VStack(spacing: 4) {
                    Image(systemName: "banknote")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(totalSpending)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Spending")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text("Made with CommuteFlex")
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.4))
            .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func recapStatRow(icon: String, label: String, value: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Spacer()

            Text(detail)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.22),
                Color(red: 0.15, green: 0.18, blue: 0.32),
                Color(red: 0.12, green: 0.20, blue: 0.38)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    MonthlyRecapCardView(
        periodTitle: "August 2026",
        totalTrips: 42,
        mostUsedTransport: (.mrtJakarta, 18),
        topStation: ("Dukuh Atas", 12),
        topCorridor: ("1", 15),
        totalDistance: "156.3 km",
        totalSpending: "Rp 252.000",
        transportBreakdown: [
            (.mrtJakarta, 18),
            (.krlCommuterLine, 12),
            (.transJakarta, 8),
            (.lrt, 4)
        ],
        hasDistance: true,
        hasSpending: true
    )
    .padding()
    .background(Color.black)
}
