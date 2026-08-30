//
//  HomeView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 18/05/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HomeViewModel()

    var body: some View {
        Group {
            if trips.isEmpty {
                emptyStateView
            } else {
                tripListView
            }
        }
        .navigationTitle("Trips")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddTrip = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Trip")
            }
        }
        .sheet(isPresented: $viewModel.showAddTrip) {
            AddTripView()
        }
    }

    private var tripListView: some View {
        List {
            ForEach(viewModel.groupedTrips(from: trips), id: \.key) {
                date,
                tripsForDate in
                Section {
                    ForEach(tripsForDate) { trip in
                        NavigationLink(
                            value: Router.HomeDestination.tripDetail(trip)
                        ) {
                            TripRowView(trip: trip)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteTrips(
                            tripsForDate,
                            at: indexSet,
                            context: modelContext
                        )
                    }
                } header: {
                    Text(
                        date,
                        format: .dateTime.weekday(.wide).day().month(.wide)
                            .year()
                    )
                }
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Trips Yet", systemImage: "tram.fill")
        } description: {
            Text("Tap the + button to log your first commute.")
        } actions: {
            Button {
                viewModel.showAddTrip = true
            } label: {
                Text("Add Trip")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Trip.self, inMemory: true)
}
