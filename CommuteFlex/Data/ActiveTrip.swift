//
//  ActiveTrip.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation

struct ActiveTrip: Codable {
    var id: UUID = UUID()
    var transportType: TransportType
    var departureStation: String
    var departureTime: Date = Date.now
    var corridorCode: String?
    var fleetCode: String?
    var vehicleModel: String?
    var notes: String?
    var fare: Double?
    var estimatedDistance: Double?
}
