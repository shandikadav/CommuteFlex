//
//  TapOutView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import SwiftUI
import SwiftData
import UIKit

struct TapOutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var tripManager: ActiveTripManager
    @State private var viewModel = TapOutViewModel()
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                headerView

                // MARK: - Content
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.nearbyStations.isEmpty {
                    emptyView
                } else {
                    stationListView
                }

                Spacer(minLength: 0)

                // MARK: - Bottom action
                if viewModel.selectedStation != nil {
                    confirmSection
                }
            }
            .navigationTitle("Tap Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await viewModel.requestTapOut()
            }
        }
    }

    // MARK: - Sub‑views

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeating)

            Text("Arriving at Destination")
                .font(.headline)

            if let active = tripManager.activeTrip {
                Text("From **\(active.departureStation)**")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Elapsed: \(active.departureTime, style: .timer)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Text("Choose your arrival stop to complete the trip.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Searching…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Location Error", systemImage: "location.slash.fill")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.requestTapOut() }
            }
            .buttonStyle(.bordered)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Stations Found", systemImage: "mappin.slash")
        } description: {
            Text("We couldn't find nearby transit stops. Try moving closer to a station.")
        } actions: {
            Button("Retry") {
                Task { await viewModel.requestTapOut() }
            }
            .buttonStyle(.bordered)
        }
    }

    private var stationListView: some View {
        List(viewModel.filteredStations, selection: Binding(
            get: { viewModel.selectedStation?.id },
            set: { newID in
                viewModel.selectedStation = viewModel.filteredStations.first { $0.id == newID }
            }
        )) { station in
            Button {
                withAnimation { viewModel.selectedStation = station }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: station.suggestedTransport?.iconName ?? "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.name)
                            .font(.body.weight(.medium))

                        if let transport = station.suggestedTransport {
                            Text(transport.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Text(station.distanceString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if viewModel.selectedStation?.id == station.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.orange)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredStations.isEmpty {
                ContentUnavailableView("No Matching Stations", systemImage: "line.3.horizontal.decrease.circle", description: Text("Try another operator or search term."))
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("Transit operator", selection: $viewModel.stationFilter) {
                ForEach(NearbyStationFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .searchable(text: $viewModel.searchText, prompt: "Search station")
    }

    private var confirmSection: some View {
        VStack(spacing: 12) {
            Divider()

            DisclosureGroup("Trip details") {
                VStack(spacing: 10) {
                    TextField("Fare (Rp)", text: $viewModel.fareText)
                        .keyboardType(.numberPad)
                    TextField("Estimated distance (km)", text: $viewModel.distanceText)
                        .keyboardType(.decimalPad)
                    TextField("Corridor / line code", text: $viewModel.corridorCode)
                    TextField("Fleet code", text: $viewModel.fleetCode)
                    TextField("Vehicle model", text: $viewModel.vehicleModel)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.top, 8)
            }
            .padding(.horizontal)

            Button {
                guard tripManager.activeTrip != nil else { return }
                do {
                    try viewModel.confirmTapOut(manager: tripManager, context: modelContext)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                } catch {
                    saveError = error.localizedDescription
                }
            } label: {
                Label("Tap Out", systemImage: "wave.3.left")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
        .alert("Couldn't Save Trip", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) { saveError = nil }
        } message: {
            Text(saveError ?? "Please try again.")
        }
    }
}
