//
//  TripDetailView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftData
import SwiftUI

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = TripDetailViewModel()

    var body: some View {
        Form {

            Section {
                Picker("Transport Type", selection: $trip.transportType) {
                    ForEach(TransportType.allCases) { type in
                        Label(type.displayName, systemImage: type.iconName)
                            .tag(type)
                    }
                }
            }

            Section("Route") {
                TextField("Departure Station", text: $trip.departureStation)
                    .textInputAutocapitalization(.words)

                TextField("Arrival Station", text: $trip.arrivalStation)
                    .textInputAutocapitalization(.words)

                DatePicker("Date & Time", selection: $trip.date)
            }

            Section {
                DisclosureGroup(
                    "Enthusiast Details",
                    isExpanded: $viewModel.showEnthusiastDetails
                ) {
                    TextField(
                        "Corridor / Line Code",
                        text: Binding(
                            get: { trip.corridorCode ?? "" },
                            set: { trip.corridorCode = $0.isEmpty ? nil : $0 }
                        )
                    )
                    .textInputAutocapitalization(.characters)

                    TextField(
                        "Fleet Code",
                        text: Binding(
                            get: { trip.fleetCode ?? "" },
                            set: { trip.fleetCode = $0.isEmpty ? nil : $0 }
                        )
                    )
                    .textInputAutocapitalization(.characters)

                    TextField(
                        "Vehicle Model",
                        text: Binding(
                            get: { trip.vehicleModel ?? "" },
                            set: { trip.vehicleModel = $0.isEmpty ? nil : $0 }
                        )
                    )
                    .textInputAutocapitalization(.words)

                    TextField("Fare (Rp)", text: $viewModel.fareText)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.fareText) {
                            viewModel.updateFare(for: trip)
                        }

                    TextField(
                        "Estimated Distance (km)",
                        text: $viewModel.distanceText
                    )
                    .keyboardType(.decimalPad)
                    .onChange(of: viewModel.distanceText) {
                        viewModel.updateDistance(for: trip)
                    }

                    TextField(
                        "Notes",
                        text: Binding(
                            get: { trip.notes ?? "" },
                            set: { trip.notes = $0.isEmpty ? nil : $0 }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
            }

            Section {
                Button("Delete Trip", role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this trip?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteTrip(trip, context: modelContext)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            viewModel.initializeFields(from: trip)
        }
    }
}
