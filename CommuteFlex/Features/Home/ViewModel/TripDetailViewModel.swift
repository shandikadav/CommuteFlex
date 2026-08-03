//
//  TripDetailViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation
import SwiftData

@Observable
final class TripDetailViewModel {
    var showDeleteConfirmation = false
    var showEnthusiastDetails = false
    var fareText = ""
    var distanceText = ""

    func initializeFields(from trip: Trip) {
        if let fare = trip.fare {
            fareText = String(format: "%.0f", fare)
        }
        if let distance = trip.estimatedDistance {
            distanceText = String(format: "%.1f", distance)
        }

        showEnthusiastDetails =
            trip.corridorCode != nil
            || trip.fleetCode != nil
            || trip.vehicleModel != nil
            || trip.notes != nil
            || trip.fare != nil
            || trip.estimatedDistance != nil
    }

    func updateFare(for trip: Trip) {
        trip.fare = Double(fareText)
    }

    func updateDistance(for trip: Trip) {
        trip.estimatedDistance = Double(distanceText)
    }

    func deleteTrip(_ trip: Trip, context: ModelContext) {
        context.delete(trip)
    }
}
