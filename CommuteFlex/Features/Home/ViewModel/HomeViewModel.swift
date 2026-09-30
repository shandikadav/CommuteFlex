//
//  HomeViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation
import SwiftData

@Observable
final class HomeViewModel {
    var showAddTrip = false
    var tripManager = ActiveTripManager()

    /// Whether the user is currently on a trip.
    var isInTransit: Bool {
        tripManager.activeTrip != nil
    }

    func groupedTrips(from trips: [Trip]) -> [(key: Date, value: [Trip])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: trips) { trip in
            calendar.startOfDay(for: trip.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    func deleteTrips(
        _ tripsForDate: [Trip],
        at offsets: IndexSet,
        context: ModelContext
    ) {
        for index in offsets {
            context.delete(tripsForDate[index])
        }
    }
}
