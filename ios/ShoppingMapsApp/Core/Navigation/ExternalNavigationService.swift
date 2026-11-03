import SwiftUI
import MapKit

// MARK: - Aplicativos de Navegação Suportados (Apple Maps, Waze, Google Maps)

public enum ExternalNavigationApp: String, CaseIterable, Identifiable, Sendable {
    case appleMaps
    case waze
    case googleMaps

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .appleMaps:
            return "Apple Maps"
        case .waze:
            return "Waze"
        case .googleMaps:
            return "Google Maps"
        }
    }

    public var iconName: String {
        switch self {
        case .appleMaps:
            return "map.fill"
        case .waze:
            return "location.north.line.fill"
        case .googleMaps:
            return "globe.americas.fill"
        }
    }

    public var iconColor: Color {
        switch self {
        case .appleMaps:
            return .blue
        case .waze:
            return .cyan
        case .googleMaps:
            return .red
        }
    }
}

// MARK: - Serviço de Disparo de Navegação Externa

@MainActor
public final class ExternalNavigationService {
    public static let shared = ExternalNavigationService()

    private init() {}

    public func open(
        app: ExternalNavigationApp,
        destination: CLLocationCoordinate2D,
        destinationName: String
    ) {
        let lat = destination.latitude
        let lon = destination.longitude

        switch app {
        case .appleMaps:
            let placemark = MKPlacemark(coordinate: destination)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = destinationName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])

        case .waze:
            if let wazeURL = URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes"),
               UIApplication.shared.canOpenURL(wazeURL) {
                UIApplication.shared.open(wazeURL)
            } else if let webWaze = URL(string: "https://waze.com/ul?ll=\(lat),\(lon)&navigate=yes") {
                UIApplication.shared.open(webWaze)
            }

        case .googleMaps:
            if let gmapsURL = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving"),
               UIApplication.shared.canOpenURL(gmapsURL) {
                UIApplication.shared.open(gmapsURL)
            } else if let webGMaps = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)") {
                UIApplication.shared.open(webGMaps)
            }
        }
    }
}
