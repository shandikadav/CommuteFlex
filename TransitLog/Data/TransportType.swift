//
//  TransportType.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import Foundation

enum TransportType: String, Codable, CaseIterable, Identifiable {
    case transJakarta
    case mrtJakarta
    case krlCommuterLine
    case lrt
    case busShuttle
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .transJakarta: "TransJakarta"
        case .mrtJakarta: "MRT Jakarta"
        case .krlCommuterLine: "KRL Commuter Line"
        case .lrt: "LRT"
        case .busShuttle: "Bus / Shuttle"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .transJakarta: "bus.fill"
        case .mrtJakarta: "tram.fill"
        case .krlCommuterLine: "train.side.front.car"
        case .lrt: "lightrail.fill"
        case .busShuttle: "bus.doubledecker.fill"
        case .other: "car.fill"
        }
    }

    var tintColor: String {
        switch self {
        case .transJakarta: "red"
        case .mrtJakarta: "blue"
        case .krlCommuterLine: "orange"
        case .lrt: "purple"
        case .busShuttle: "green"
        case .other: "gray"
        }
    }
}
