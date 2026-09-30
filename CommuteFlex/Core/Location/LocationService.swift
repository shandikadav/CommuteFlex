//
//  LocationService.swift
//  CommuteFlex
//
import CoreLocation
import Foundation
import SwiftUI

@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var lastLocation: CLLocation?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() async throws -> CLAuthorizationStatus {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return authorizationStatus
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .notDetermined:
            return try await withCheckedThrowingContinuation { continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        @unknown default:
            throw LocationError.permissionDenied
        }
    }

    func requestLocation() async throws -> CLLocation {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            throw LocationError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        guard let continuation = authorizationContinuation else { return }
        authorizationContinuation = nil
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            continuation.resume(returning: authorizationStatus)
        case .denied, .restricted:
            continuation.resume(throwing: LocationError.permissionDenied)
        case .notDetermined:
            break
        @unknown default:
            continuation.resume(throwing: LocationError.permissionDenied)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

private enum LocationError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        "Location access is unavailable. Enable location access in Settings and try again."
    }
}
