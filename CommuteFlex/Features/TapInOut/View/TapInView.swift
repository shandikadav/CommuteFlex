//
//  TapInView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import SwiftUI
import UIKit

struct TapInView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var tripManager: ActiveTripManager
    @State private var viewModel: TapInViewModel

    init(tripManager: ActiveTripManager) {
        self.tripManager = tripManager
        _viewModel = State(initialValue: TapInViewModel(manager: tripManager))
    }

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
            .navigationTitle("Tap In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await viewModel.requestTapIn()
            }
        }
    }

    // MARK: - Sub‑views

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse, options: .repeating)

            Text("Detecting Nearby Stations")
                .font(.headline)

            Text("Choose your departure stop to start your trip.")
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
                Task { await viewModel.requestTapIn() }
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
                Task { await viewModel.requestTapIn() }
            }
            .buttonStyle(.bordered)
        }
    }

    private var stationListView: some View {
        List(viewModel.filteredStations, selection: Binding(
            get: { viewModel.selectedStation?.id },
            set: { newID in
                if let station = viewModel.filteredStations.first(where: { $0.id == newID }) {
                    viewModel.select(station)
                }
            }
        )) { station in
            Button {
                withAnimation { viewModel.select(station) }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: station.suggestedTransport?.iconName ?? "mappin.and.ellipse")
                        .font(.title2)
                        .foregroundStyle(.tint)
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
                            .foregroundStyle(.tint)
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

            // Transport picker
            Picker("Transport", selection: $viewModel.selectedTransport) {
                ForEach(TransportType.allCases) { type in
                    Label(type.displayName, systemImage: type.iconName).tag(type)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            DisclosureGroup("Trip details") {
                VStack(spacing: 10) {
                    TextField("Corridor / line code", text: $viewModel.corridorCode)
                    TextField("Fleet code", text: $viewModel.fleetCode)
                    TextField("Vehicle model", text: $viewModel.vehicleModel)
                    TextField("Fare (Rp)", text: $viewModel.fareText)
                        .keyboardType(.numberPad)
                    TextField("Estimated distance (km)", text: $viewModel.distanceText)
                        .keyboardType(.decimalPad)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.top, 8)
            }
            .padding(.horizontal)

            Button {
                viewModel.confirmTapIn()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                tripManager.showTapIn = false
                dismiss()
            } label: {
                Label("Tap In", systemImage: "wave.3.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}
