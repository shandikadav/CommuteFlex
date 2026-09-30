//
//  ActiveTripManager.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation
import SwiftUI
import SwiftData

@Observable
final class ActiveTripManager {
    var activeTrip: ActiveTrip?
    var showTapIn: Bool = false
    var showTapOut: Bool = false
    private let storageKey = "ActiveTripState"

    init() {
        loadFromStorage()
    }

    // MARK: - Persistence
    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let trip = try decoder.decode(ActiveTrip.self, from: data)
            self.activeTrip = trip
        } catch {
            print("⚠️ Failed to decode ActiveTrip: \(error)")
        }
    }

    private func saveToStorage() {
        guard let trip = activeTrip else { UserDefaults.standard.removeObject(forKey: storageKey); return }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(trip)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode ActiveTrip: \(error)")
        }
    }

    // MARK: - Tap In / Out actions
    func startTrip(transport: TransportType, departureStation: String, corridor: String? = nil, fleet: String? = nil, vehicle: String? = nil, notes: String? = nil, fare: Double? = nil, distance: Double? = nil) {
        let trip = ActiveTrip(
            transportType: transport,
            departureStation: departureStation,
            departureTime: .now,
            corridorCode: corridor,
            fleetCode: fleet,
            vehicleModel: vehicle,
            notes: notes,
            fare: fare,
            estimatedDistance: distance
        )
        self.activeTrip = trip
        saveToStorage()
        showTapIn = false
    }

    func finishTrip(arrivalStation: String, arrivalTime: Date = .now, context: ModelContext) throws {
        guard let active = activeTrip else { return }
        let completed = Trip(
            transportType: active.transportType,
            departureStation: active.departureStation,
            arrivalStation: arrivalStation,
            date: active.departureTime,
            createdAt: arrivalTime,
            corridorCode: active.corridorCode,
            fleetCode: active.fleetCode,
            vehicleModel: active.vehicleModel,
            notes: active.notes,
            fare: active.fare,
            estimatedDistance: active.estimatedDistance
        )
        context.insert(completed)
        do {
            try context.save()
        } catch {
            context.delete(completed)
            throw error
        }
        self.activeTrip = nil
        saveToStorage()
        showTapOut = false
    }

    func cancelTrip() {
        activeTrip = nil
        showTapOut = false
        saveToStorage()
    }
}
