//
//  StatsViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation

@Observable
final class StatsViewModel {

    func mostUsedTransportType(from trips: [Trip]) -> (
        type: TransportType, count: Int
    )? {
        let counts = Dictionary(grouping: trips, by: \.transportType)
            .mapValues(\.count)

        guard let max = counts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (max.key, max.value)
    }

    func mostVisitedStation(from trips: [Trip]) -> (
        station: String, count: Int
    )? {
        let allStations = trips.flatMap {
            [$0.departureStation, $0.arrivalStation]
        }
        let counts = Dictionary(grouping: allStations, by: { $0 })
            .mapValues(\.count)

        guard let max = counts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (max.key, max.value)
    }

    func mostUsedCorridorOrLine(from trips: [Trip]) -> (
        corridor: String, count: Int
    )? {
        let corridors = trips.compactMap(\.corridorCode).filter { !$0.isEmpty }
        guard !corridors.isEmpty else { return nil }

        let counts = Dictionary(grouping: corridors, by: { $0 })
            .mapValues(\.count)

        guard let max = counts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (max.key, max.value)
    }

    func totalEstimatedDistance(from trips: [Trip]) -> Double {
        trips.compactMap(\.estimatedDistance).reduce(0, +)
    }

    func totalEstimatedSpending(from trips: [Trip]) -> Double {
        trips.compactMap(\.fare).reduce(0, +)
    }

    func formattedDistance(from trips: [Trip]) -> String {
        let distance = totalEstimatedDistance(from: trips)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        let measurement = Measurement(
            value: distance,
            unit: UnitLength.kilometers
        )
        return formatter.string(from: measurement)
    }

    func formattedSpending(from trips: [Trip]) -> String {
        let spending = totalEstimatedSpending(from: trips)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: spending)) ?? "Rp 0"
    }
}
