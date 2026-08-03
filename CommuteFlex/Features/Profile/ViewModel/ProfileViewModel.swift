//
//  ProfileViewModel.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation

@Observable
final class ProfileViewModel {

    func uniqueTransportTypes(from trips: [Trip]) -> Int {
        Set(trips.map(\.transportType)).count
    }

    func uniqueStations(from trips: [Trip]) -> Int {
        Set(trips.flatMap { [$0.departureStation, $0.arrivalStation] }).count
    }

    var appVersion: String {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
        let build =
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
