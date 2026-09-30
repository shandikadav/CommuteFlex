//
//  TransitStation.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import Foundation
import CoreLocation

enum NearbyStationFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case transJakarta
    case mrt
    case lrt
    case krl

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .transJakarta: "TJ"
        case .mrt: "MRT"
        case .lrt: "LRT"
        case .krl: "KRL"
        }
    }

    var transportType: TransportType? {
        switch self {
        case .all: nil
        case .transJakarta: .transJakarta
        case .mrt: .mrtJakarta
        case .lrt: .lrt
        case .krl: .krlCommuterLine
        }
    }
}

struct TransitStation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let suggestedTransport: TransportType?

    var distanceString: String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters)) m"
        } else {
            let km = distanceMeters / 1000.0
            return String(format: "%.1f km", km)
        }
    }
}
