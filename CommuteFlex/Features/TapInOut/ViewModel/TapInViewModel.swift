//
//  TapInViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation
import CoreLocation
import SwiftData
import SwiftUI

@Observable
final class TapInViewModel {
    var nearbyStations: [TransitStation] = []
    var isLoading = false
    var errorMessage: String?
    var selectedStation: TransitStation?
    var searchText = ""
    var stationFilter: NearbyStationFilter = .all
    var selectedTransport: TransportType = .transJakarta
    var corridorCode: String = ""
    var fleetCode: String = ""
    var vehicleModel: String = ""
    var notes: String = ""
    var fareText: String = ""
    var distanceText: String = ""

    private let locationService = LocationService()
    private let searchService = TransitSearchService()
    private let manager: ActiveTripManager

    init(manager: ActiveTripManager) {
        self.manager = manager
    }

    var filteredStations: [TransitStation] {
        nearbyStations.filter { station in
            let matchesSearch = searchText.isEmpty || station.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = stationFilter.transportType.map { station.suggestedTransport == $0 } ?? true
            return matchesSearch && matchesFilter
        }
    }

    func select(_ station: TransitStation) {
        selectedStation = station
        if let suggested = station.suggestedTransport {
            selectedTransport = suggested
        }
    }

    func requestTapIn() async {
        isLoading = true
        errorMessage = nil
        do {
            // 1️⃣ Request location permission & fetch location.
            _ = try await locationService.requestPermission()
            let location = try await locationService.requestLocation()
            // 2️⃣ Search nearby public‑transport POIs.
            var stations = try await searchService.searchNearbyStations(coordinate: location.coordinate)
            if stations.count < 3 {
                let fallback = try await searchService.fallbackSearch(query: "Halte OR Stasiun", near: location.coordinate)
                stations = searchService.merging(stations, with: fallback)
            }
            self.nearbyStations = stations
        } catch {
            errorMessage = "Unable to locate nearby stations: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func confirmTapIn() {
        guard let station = selectedStation else { return }
        manager.startTrip(
            transport: selectedTransport,
            departureStation: station.name,
            corridor: corridorCode.isEmpty ? nil : corridorCode,
            fleet: fleetCode.isEmpty ? nil : fleetCode,
            vehicle: vehicleModel.isEmpty ? nil : vehicleModel,
            notes: notes.isEmpty ? nil : notes,
            fare: Double(fareText),
            distance: Double(distanceText)
        )
    }
}
