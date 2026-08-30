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

    private var filtered: [Trip] {
        viewModel.filteredTrips(from: trips)
    }

    var body: some View {
        Group {
            if trips.isEmpty {
                emptyStateView
            } else {
                statsContentView
            }
        }
        .navigationTitle("Statistics")
        .toolbar {
            if viewModel.selectedMonth != nil && !filtered.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showMonthlyRecap = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share Monthly Recap")
                }
            }
        }
        .sheet(isPresented: $viewModel.showMonthlyRecap) {
            if let month = viewModel.selectedMonth {
                MonthlyRecapView(
                    month: month,
                    trips: filtered
                )
            }
        }
    }

    // MARK: - Stats Content

    private var statsContentView: some View {
        List {
            // MARK: - Month Picker

            Section {
                monthPickerView
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowBackground(Color.clear)

            if filtered.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No Trips This Month", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("You didn't log any trips this month.")
                    }
                }
                .listRowBackground(Color.clear)
            } else {
                // MARK: - Overview

                Section("Overview") {
                    StatCardView(
                        iconName: "number",
                        title: "Total Trips",
                        value: "\(filtered.count)"
                    )
                }

                // MARK: - Favorites

                Section("Favorites") {
                    if let mostUsedTransport = viewModel.mostUsedTransportType(from: filtered) {
                        StatCardView(
                            iconName: mostUsedTransport.type.iconName,
                            title: "Most Used Transport",
                            value: mostUsedTransport.type.displayName,
                            subtitle: "\(mostUsedTransport.count) trips"
                        )
                    }

                    if let mostVisited = viewModel.mostVisitedStation(from: filtered) {
                        StatCardView(
                            iconName: "mappin.and.ellipse",
                            title: "Most Visited Station",
                            value: mostVisited.station,
                            subtitle: "\(mostVisited.count) visits"
                        )
                    }

                    if let mostUsedCorridor = viewModel.mostUsedCorridorOrLine(from: filtered) {
                        StatCardView(
                            iconName: "arrow.triangle.branch",
                            title: "Most Used Corridor / Line",
                            value: mostUsedCorridor.corridor,
                            subtitle: "\(mostUsedCorridor.count) trips"
                        )
                    }
                }

                // MARK: - Totals

                Section("Totals") {
                    if viewModel.totalEstimatedDistance(from: filtered) > 0 {
                        StatCardView(
                            iconName: "point.topleft.down.to.point.bottomright.curvepath",
                            title: "Total Estimated Distance",
                            value: viewModel.formattedDistance(from: filtered)
                        )
                    }

                    if viewModel.totalEstimatedSpending(from: filtered) > 0 {
                        StatCardView(
                            iconName: "banknote",
                            title: "Estimated Total Spending",
                            value: viewModel.formattedSpending(from: filtered)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Month Picker

    private var monthPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Time chip
                monthChip(label: "All Time", isSelected: viewModel.selectedMonth == nil) {
                    withAnimation(.snappy) {
                        viewModel.selectedMonth = nil
                    }
                }

                // Month chips
                ForEach(viewModel.availableMonths(from: trips), id: \.self) { month in
                    monthChip(
                        label: viewModel.monthDisplayName(month),
                        isSelected: isSameMonth(viewModel.selectedMonth, month)
                    ) {
                        withAnimation(.snappy) {
                            viewModel.selectedMonth = month
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func monthChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyShapeStyle(.tint)
                        : AnyShapeStyle(.fill.quaternary)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Empty State (No trips at all)

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Statistics Yet", systemImage: "chart.bar")
        } description: {
            Text("Start logging trips to see your commuting insights.")
        }
    }

    // MARK: - Helpers

    private func isSameMonth(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        let calendar = Calendar.current
        return calendar.component(.year, from: a) == calendar.component(.year, from: b)
            && calendar.component(.month, from: a) == calendar.component(.month, from: b)
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(for: Trip.self, inMemory: true)
}
