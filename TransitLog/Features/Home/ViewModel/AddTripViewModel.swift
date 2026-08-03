//
//  AddTripViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation
import SwiftData

@Observable
final class AddTripViewModel {

    var transportType: TransportType = .transJakarta
    var departureStation = ""
    var arrivalStation = ""
    var date: Date = .now

    var corridorCode = ""
    var fleetCode = ""
    var vehicleModel = ""
    var notes = ""
    var fareText = ""
    var distanceText = ""

    var showEnthusiastDetails = false

    var canSave: Bool {
        !departureStation.trimmingCharacters(in: .whitespaces).isEmpty
            && !arrivalStation.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func saveTrip(context: ModelContext) {
        let trip = Trip(
            transportType: transportType,
            departureStation: departureStation.trimmingCharacters(
                in: .whitespaces
            ),
            arrivalStation: arrivalStation.trimmingCharacters(in: .whitespaces),
            date: date,
            corridorCode: corridorCode.isEmpty
                ? nil : corridorCode.trimmingCharacters(in: .whitespaces),
            fleetCode: fleetCode.isEmpty
                ? nil : fleetCode.trimmingCharacters(in: .whitespaces),
            vehicleModel: vehicleModel.isEmpty
                ? nil : vehicleModel.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty
                ? nil : notes.trimmingCharacters(in: .whitespaces),
            fare: Double(fareText),
            estimatedDistance: Double(distanceText)
        )

        context.insert(trip)
    }
}
