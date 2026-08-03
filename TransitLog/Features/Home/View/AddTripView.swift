//
//  AddTripView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftData
import SwiftUI

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddTripViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Transport Type

                Section {
                    Picker("Transport Type", selection: $viewModel.transportType) {
                        ForEach(TransportType.allCases) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                }

                // MARK: - Route Details

                Section("Route") {
                    TextField("Departure Station", text: $viewModel.departureStation)
                        .textInputAutocapitalization(.words)

                    TextField("Arrival Station", text: $viewModel.arrivalStation)
                        .textInputAutocapitalization(.words)

                    DatePicker("Date & Time", selection: $viewModel.date)
                }

                // MARK: - Enthusiast Details (Expandable)

                Section {
                    DisclosureGroup("Enthusiast Details", isExpanded: $viewModel.showEnthusiastDetails) {
                        TextField("Corridor / Line Code", text: $viewModel.corridorCode)
                            .textInputAutocapitalization(.characters)

                        TextField("Fleet Code", text: $viewModel.fleetCode)
                            .textInputAutocapitalization(.characters)

                        TextField("Vehicle Model", text: $viewModel.vehicleModel)
                            .textInputAutocapitalization(.words)

                        TextField("Fare (Rp)", text: $viewModel.fareText)
                            .keyboardType(.numberPad)

                        TextField("Estimated Distance (km)", text: $viewModel.distanceText)
                            .keyboardType(.decimalPad)

                        TextField("Notes", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveTrip(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AddTripView()
        .modelContainer(for: Trip.self, inMemory: true)
}
