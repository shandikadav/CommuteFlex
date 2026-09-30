//
//  TapOutViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation
import CoreLocation
import SwiftData

@Observable
final class TapOutViewModel {
    var nearbyStations: [TransitStation] = []
    var isLoading = false
    var errorMessage: String?
    var selectedStation: TransitStation?
    var searchText = ""
    var stationFilter: NearbyStationFilter = .all
    var fareText = ""
    var distanceText = ""
    var corridorCode = ""
    var fleetCode = ""
    var vehicleModel = ""
    var notes = ""

    private let locationService = LocationService()
    private let searchService = TransitSearchService()

    var filteredStations: [TransitStation] {
        nearbyStations.filter { station in
            let matchesSearch = searchText.isEmpty || station.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = stationFilter.transportType.map { station.suggestedTransport == $0 } ?? true
            return matchesSearch && matchesFilter
        }
    }

    /// Fetch nearby stations for the tap‑out selection.
    func requestTapOut() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await locationService.requestPermission()
            let location = try await locationService.requestLocation()
            var stations = try await searchService.searchNearbyStations(coordinate: location.coordinate)
            if stations.isEmpty {
                stations = try await searchService.fallbackSearch(query: "Halte OR Stasiun", near: location.coordinate)
            }
            self.nearbyStations = stations
        } catch {
            errorMessage = "Unable to locate nearby stations: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Finalize the trip: save a completed `Trip` to SwiftData and clear the active trip.
    func confirmTapOut(manager: ActiveTripManager, context: ModelContext) throws {
        guard manager.activeTrip != nil, let station = selectedStation else { return }
        if let fare = Double(fareText) { manager.activeTrip?.fare = fare }
        if let distance = Double(distanceText) { manager.activeTrip?.estimatedDistance = distance }
        if !corridorCode.isEmpty { manager.activeTrip?.corridorCode = corridorCode }
        if !fleetCode.isEmpty { manager.activeTrip?.fleetCode = fleetCode }
        if !vehicleModel.isEmpty { manager.activeTrip?.vehicleModel = vehicleModel }
        if !notes.isEmpty { manager.activeTrip?.notes = notes }
        try manager.finishTrip(arrivalStation: station.name, context: context)
    }
}
