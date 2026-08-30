//
//  Trip.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID
    var transportType: TransportType
    var departureStation: String
    var arrivalStation: String
    var date: Date
    var createdAt: Date

    var corridorCode: String?
    var fleetCode: String?
    var vehicleModel: String?
    var notes: String?
    var fare: Double?
    var estimatedDistance: Double?

    init(
        id: UUID = UUID(),
        transportType: TransportType,
        departureStation: String,
        arrivalStation: String,
        date: Date = .now,
        createdAt: Date = .now,
        corridorCode: String? = nil,
        fleetCode: String? = nil,
        vehicleModel: String? = nil,
        notes: String? = nil,
        fare: Double? = nil,
        estimatedDistance: Double? = nil
    ) {
        self.id = id
        self.transportType = transportType
        self.departureStation = departureStation
        self.arrivalStation = arrivalStation
        self.date = date
        self.createdAt = createdAt
        self.corridorCode = corridorCode
        self.fleetCode = fleetCode
        self.vehicleModel = vehicleModel
        self.notes = notes
        self.fare = fare
        self.estimatedDistance = estimatedDistance
    }
}
