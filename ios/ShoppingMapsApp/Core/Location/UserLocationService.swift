import Foundation
import CoreLocation
import MapKit

// MARK: - Serviço de Localização do Usuário e Cálculo de Distância / ETA

@Observable
@MainActor
public final class UserLocationService: NSObject, CLLocationManagerDelegate {
    public static let shared = UserLocationService()

    private let locationManager = CLLocationManager()

    public private(set) var userLocation: CLLocationCoordinate2D?
    public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    public private(set) var isCalculatingETA: Bool = false
    public private(set) var lastCalculatedETA: (distance: CLLocationDistance, travelTime: TimeInterval)?

    private var lastETACoordinate: CLLocationCoordinate2D?
    private var lastETATimestamp: Date?

    public override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.authorizationStatus = locationManager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    public func requestAuthorization() {
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    public func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silencia falhas transitórias em simulador / túneis
    }

    // MARK: - Cálculos de Distância e Tempo de Deslocamento (ETA)

    /// Calcula a distância direta (linha reta) entre o usuário e um destino
    public func directDistance(to destination: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let userLocation else { return nil }
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let destLoc = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return userLoc.distance(from: destLoc)
    }

    /// Calcula a rota de carro em tempo real via MapKit (MKDirections) retornando distância e tempo
    public func fetchDrivingETA(to destination: CLLocationCoordinate2D) async -> (distance: CLLocationDistance, travelTime: TimeInterval)? {
        guard let userLocation else { return nil }

        // Cache de 60 segundos se o usuário não se moveu significativamente
        if let lastCalculatedETA,
           let lastCoord = lastETACoordinate,
           let lastTime = lastETATimestamp,
           Date().timeIntervalSince(lastTime) < 60,
           abs(lastCoord.latitude - userLocation.latitude) < 0.001,
           abs(lastCoord.longitude - userLocation.longitude) < 0.001 {
            return lastCalculatedETA
        }

        isCalculatingETA = true
        defer { isCalculatingETA = false }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        do {
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            if let primaryRoute = response.routes.first {
                let eta = (distance: primaryRoute.distance, travelTime: primaryRoute.expectedTravelTime)
                self.lastCalculatedETA = eta
                self.lastETACoordinate = userLocation
                self.lastETATimestamp = Date()
                return eta
            }
        } catch {
            // Em caso de falha de conexão ou fora da malha, calcula distância euclidiana estimada a 35km/h
            if let directDist = directDistance(to: destination) {
                let estimatedSeconds = (directDist / 1000.0) / 35.0 * 3600.0
                let fallback = (distance: directDist, travelTime: max(estimatedSeconds, 60))
                self.lastCalculatedETA = fallback
                return fallback
            }
        }

        return nil
    }

    // MARK: - Formatadores de Apresentação

    public func formatDistance(_ distanceMeters: CLLocationDistance) -> String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters.rounded())) m"
        } else {
            let km = distanceMeters / 1000.0
            return km.formatted(.number.precision(.fractionLength(1))) + " km"
        }
    }

    public func formatTravelTime(_ seconds: TimeInterval) -> String {
        let minutes = max(1, Int((seconds / 60.0).rounded()))
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) h"
            }
            return "\(hours) h \(remainingMinutes) min"
        }
    }
}

