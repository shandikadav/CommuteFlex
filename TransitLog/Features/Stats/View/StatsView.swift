//
//  StatsView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 18/05/26.
//

import SwiftData
import SwiftUI

struct StatsView: View {
    @Query private var trips: [Trip]

    @State private var viewModel = StatsViewModel()

    var body: some View {
        Group {
            if trips.isEmpty {
                emptyStateView
            } else {
                statsListView
            }
        }
        .navigationTitle("Statistics")
    }

    private var statsListView: some View {
        List {
            Section("Overview") {
                StatCardView(
                    iconName: "number",
                    title: "Total Trips",
                    value: "\(trips.count)"
                )
            }

            Section("Favorites") {
                if let mostUsedTransport = viewModel.mostUsedTransportType(from: trips) {
                    StatCardView(
                        iconName: mostUsedTransport.type.iconName,
                        title: "Most Used Transport",
                        value: mostUsedTransport.type.displayName,
                        subtitle: "\(mostUsedTransport.count) trips"
                    )
                }

                if let mostVisited = viewModel.mostVisitedStation(from: trips) {
                    StatCardView(
                        iconName: "mappin.and.ellipse",
                        title: "Most Visited Station",
                        value: mostVisited.station,
                        subtitle: "\(mostVisited.count) visits"
                    )
                }

                if let mostUsedCorridor = viewModel.mostUsedCorridorOrLine(from: trips) {
                    StatCardView(
                        iconName: "arrow.triangle.branch",
                        title: "Most Used Corridor / Line",
                        value: mostUsedCorridor.corridor,
                        subtitle: "\(mostUsedCorridor.count) trips"
                    )
                }
            }

            Section("Totals") {
                if viewModel.totalEstimatedDistance(from: trips) > 0 {
                    StatCardView(
                        iconName: "point.topleft.down.to.point.bottomright.curvepath",
                        title: "Total Estimated Distance",
                        value: viewModel.formattedDistance(from: trips)
                    )
                }

                if viewModel.totalEstimatedSpending(from: trips) > 0 {
                    StatCardView(
                        iconName: "banknote",
                        title: "Estimated Total Spending",
                        value: viewModel.formattedSpending(from: trips)
                    )
                }
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Statistics Yet", systemImage: "chart.bar")
        } description: {
            Text("Start logging trips to see your commuting insights.")
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(for: Trip.self, inMemory: true)
}
