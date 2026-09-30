//
//  StatsViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation
import SwiftUI

@Observable
final class StatsViewModel {

    // MARK: - Month Selection

    /// nil means "All Time"
    var selectedMonth: Date? = nil
    var showStatisticsShare = false

    // MARK: - Month Filtering

    func filteredTrips(from trips: [Trip]) -> [Trip] {
        guard let month = selectedMonth else { return trips }
        return tripsForMonth(month, from: trips)
    }

    func tripsForMonth(_ month: Date, from trips: [Trip]) -> [Trip] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        return trips.filter { trip in
            let tripComponents = calendar.dateComponents([.year, .month], from: trip.date)
            return tripComponents.year == components.year && tripComponents.month == components.month
        }
    }

    func availableMonths(from trips: [Trip]) -> [Date] {
        let calendar = Calendar.current
        let months = Set(trips.map { trip in
            calendar.dateComponents([.year, .month], from: trip.date)
        })
        return months
            .compactMap { calendar.date(from: $0) }
            .sorted(by: >)
    }

    func monthDisplayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    func monthFullDisplayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Statistics

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

    // MARK: - Transport Breakdown

    func transportBreakdown(from trips: [Trip]) -> [(type: TransportType, count: Int)] {
        Dictionary(grouping: trips, by: \.transportType)
            .map { (type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Formatting

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

    // MARK: - Render Share Image

    @MainActor
    func renderStatisticsImage(for trips: [Trip], periodTitle: String) -> UIImage? {
        let cardView = MonthlyRecapCardView(
            periodTitle: periodTitle,
            totalTrips: trips.count,
            mostUsedTransport: mostUsedTransportType(from: trips),
            topStation: mostVisitedStation(from: trips),
            topCorridor: mostUsedCorridorOrLine(from: trips),
            totalDistance: formattedDistance(from: trips),
            totalSpending: formattedSpending(from: trips),
            transportBreakdown: transportBreakdown(from: trips),
            hasDistance: totalEstimatedDistance(from: trips) > 0,
            hasSpending: totalEstimatedSpending(from: trips) > 0
        )

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0 // High resolution for sharing
        return renderer.uiImage
    }
}
