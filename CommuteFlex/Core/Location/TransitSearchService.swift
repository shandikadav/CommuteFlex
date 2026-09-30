//
//  TransitSearchService.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation
import MapKit
import CoreLocation
import SwiftUI

@Observable
final class TransitSearchService {
    /// Search for public‑transport POIs around a coordinate.
    /// - Parameters:
    ///   - coordinate: Center point for the search.
    ///   - radius: Search radius in meters (default 1000 m).
    /// - Returns: Array of `TransitStation` sorted by distance.
    func searchNearbyStations(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance = 1000) async throws -> [TransitStation] {
        // 1️⃣ Build a POI request limited to public‑transport category.
        let filter = MKPointOfInterestFilter(including: [.publicTransport])
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: radius)
        request.pointOfInterestFilter = filter
        // Perform the request.
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        // Map MKMapItem → TransitStation.
        let stations = response.mapItems.compactMap { item -> TransitStation? in
            guard let name = item.name else { return nil }
            let stationCoordinate = item.location.coordinate
            let distance = coordinate.distance(to: stationCoordinate)
            let suggested = suggestedTransport(for: name)
            return TransitStation(name: name, coordinate: stationCoordinate, distanceMeters: distance, suggestedTransport: suggested)
        }
        // Sort nearest first.
        return stations.sorted { $0.distanceMeters < $1.distanceMeters }
    }

    /// Fallback search using a natural‑language query when POI results are empty.
    func fallbackSearch(query: String, near coordinate: CLLocationCoordinate2D, radius: CLLocationDistance = 1000) async throws -> [TransitStation] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems.compactMap { item in
            guard let name = item.name else { return nil }
            let stationCoordinate = item.location.coordinate
            let distance = coordinate.distance(to: stationCoordinate)
            return TransitStation(name: name, coordinate: stationCoordinate, distanceMeters: distance, suggestedTransport: suggestedTransport(for: name))
        }.sorted { $0.distanceMeters < $1.distanceMeters }
    }

    func merging(_ primary: [TransitStation], with fallback: [TransitStation]) -> [TransitStation] {
        let combined = primary + fallback
        var seen = Set<String>()
        return combined.filter { station in
            let key = station.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            return seen.insert(key).inserted
        }.sorted { $0.distanceMeters < $1.distanceMeters }
    }

    private func suggestedTransport(for name: String) -> TransportType? {
        let name = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        if name.contains("mrt") { return .mrtJakarta }
        if name.contains("lrt") { return .lrt }
        if name.contains("krl") || name.contains("commuter line") || name.contains("commuterline") || name.contains("stasiun") {
            return .krlCommuterLine
        }
        if name.contains("halte") || name.contains("transjakarta") || name.contains("trans jakarta") {
            return .transJakarta
        }
        if name.contains("bus") { return .busShuttle }
        return nil
    }
}

// Helper extension to compute distance between two coordinates.
private extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}
