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
    @State private var showCancelConfirmation = false

    var body: some View {
        Group {
            if trips.isEmpty && !viewModel.isInTransit {
                emptyStateView
            } else {
                tripListView
            }
        }
        .navigationTitle("Trips")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if !viewModel.isInTransit {
                        Button {
                            viewModel.tripManager.showTapIn = true
                        } label: {
                            Label("Tap In", systemImage: "wave.3.right")
                        }
                    }

                    Button {
                        viewModel.showAddTrip = true
                    } label: {
                        Label("Manual Entry", systemImage: "square.and.pencil")
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Trip")
            }
        }
        .sheet(isPresented: $viewModel.showAddTrip) {
            AddTripView()
        }
        .sheet(isPresented: $viewModel.tripManager.showTapIn) {
            TapInView(tripManager: viewModel.tripManager)
        }
        .sheet(isPresented: $viewModel.tripManager.showTapOut) {
            TapOutView(tripManager: viewModel.tripManager)
        }
        .confirmationDialog("Cancel this trip?", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
            Button("Cancel Trip", role: .destructive) {
                viewModel.tripManager.cancelTrip()
            }
        } message: {
            Text("This active trip will be discarded.")
        }
    }

    private var tripListView: some View {
        List {
            // MARK: - Active Trip Banner
            if let active = viewModel.tripManager.activeTrip {
                Section {
                    ActiveTripCardView(activeTrip: active) {
                        viewModel.tripManager.showTapOut = true
                    } onCancel: {
                        showCancelConfirmation = true
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } else {
                Section {
                    Button {
                        viewModel.tripManager.showTapIn = true
                    } label: {
                        Label("Tap In to Start a Trip", systemImage: "wave.3.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            // MARK: - Trip History
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
                viewModel.tripManager.showTapIn = true
            } label: {
                Text("Tap In")
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
