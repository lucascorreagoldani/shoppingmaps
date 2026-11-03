import SwiftUI
import MapKit

@Observable
@MainActor
public final class MallMapViewModel {
    public let mall: ShoppingMall

    // MARK: - 1. Estágio Atual do Mapa (MAP ou MALL-{andar})
    public var stage: MapStage = .map

    public var selectedFloor: FloorLevel?
    public var selectedStore: Store?
    public var userFloorCode: String? = "L1"

    // MARK: - Cache de Performance (Evita refaults contínuos do SwiftData durante gestos)
    public private(set) var sortedFloors: [FloorLevel] = []

    // MARK: - 2. Coordenadas Geográficas (Estágio MAP - Apple Maps)
    public var mallCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: mall.latitude,
            longitude: mall.longitude
        )
    }

    /// Contorno físico real do edifício no solo da cidade (OpenStreetMap OSM 72944851)
    /// Ancorado geograficamente à terra: quando afasta o zoom, reduz proporcionalmente com o quarteirão
    public var mallFootprint: [CLLocationCoordinate2D] {
        [
            CLLocationCoordinate2D(latitude: -27.589278, longitude: -48.515759),
            CLLocationCoordinate2D(latitude: -27.589533, longitude: -48.515612),
            CLLocationCoordinate2D(latitude: -27.590450, longitude: -48.515084),
            CLLocationCoordinate2D(latitude: -27.591157, longitude: -48.514676),
            CLLocationCoordinate2D(latitude: -27.591052, longitude: -48.514446),
            CLLocationCoordinate2D(latitude: -27.590967, longitude: -48.514257),
            CLLocationCoordinate2D(latitude: -27.590936, longitude: -48.514188),
            CLLocationCoordinate2D(latitude: -27.590823, longitude: -48.514253),
            CLLocationCoordinate2D(latitude: -27.590817, longitude: -48.514238),
            CLLocationCoordinate2D(latitude: -27.590795, longitude: -48.514190),
            CLLocationCoordinate2D(latitude: -27.590118, longitude: -48.514580),
            CLLocationCoordinate2D(latitude: -27.589029, longitude: -48.515208)
        ]
    }

    public let mallOrientationDegrees: Double = -33.0
    public var cameraPosition: MapCameraPosition
    public var cityCameraDistance: Double = 750.0

    /// Escala adaptativa do marcador no Apple Maps para permanecer rigorosamente contido no polígono do prédio
    public var cityAnnotationScale: CGFloat {
        if cityCameraDistance <= 750.0 {
            return 1.0
        } else if cityCameraDistance <= 1400.0 {
            return CGFloat(750.0 / cityCameraDistance)
        } else {
            return 0.54
        }
    }

    // MARK: - Estimativas de Distância e Tempo de Deslocamento
    public var userDistanceText: String?
    public var userETAText: String?
    public var rawETA: (distance: CLLocationDistance, travelTime: TimeInterval)?

    // MARK: - 3. Transformações de Câmera do Interior (Estágio MALL-{andar})
    // Os objetos ficam estáticos, quem se move é a câmera interna
    public var interiorZoom: CGFloat = 0.55
    public var lastInteriorZoom: CGFloat = 0.55
    public var interiorPan: CGSize = .zero
    public var lastInteriorPan: CGSize = .zero

    public init(
        mall: ShoppingMall,
        initialStage: MapStage = .map,
        initialFloorCode: String? = nil
    ) {
        self.mall = mall
        self.stage = initialStage

        // Cache de pisos ordenados
        self.sortedFloors = mall.floors.sorted { $0.levelOrder > $1.levelOrder }

        let center = CLLocationCoordinate2D(
            latitude: mall.latitude,
            longitude: mall.longitude
        )

        // Câmera 2D inicial do Apple Maps sobre a cidade
        self.cameraPosition = .camera(
            MapCamera(
                centerCoordinate: center,
                distance: 850,
                heading: 0,
                pitch: 0
            )
        )

        // Seleciona o piso inicial
        let targetCode = initialFloorCode ?? "L1"
        if let targetFloor = mall.floors.first(where: { $0.shortCode == targetCode }) ?? mall.floors.first {
            self.selectedFloor = targetFloor
        }
    }

    public var storesOnSelectedFloor: [Store] {
        selectedFloor?.stores ?? []
    }

    // MARK: - Transição entre Estágios

    public func enterMall(floorCode: String? = nil) {
        let code = floorCode ?? selectedFloor?.shortCode ?? "L1"
        if let targetFloor = mall.floors.first(where: { $0.shortCode == code }) {
            selectedFloor = targetFloor
        }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            stage = .mall(floorCode: code)
            recenterInteriorCamera()
        }
    }

    public func exitToCityMap() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            stage = .map
            selectedStore = nil
            recenterCityCamera()
        }
    }

    public func selectFloor(_ floor: FloorLevel) {
        guard selectedFloor?.id != floor.id else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedFloor = floor
            if stage.isMall {
                stage = .mall(floorCode: floor.shortCode)
            }
            if selectedStore?.floor?.id != floor.id {
                selectedStore = nil
            }
        }
    }

    public func selectStore(_ store: Store) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedStore = store
        }
    }

    public func clearSelection() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedStore = nil
        }
    }

    // MARK: - Controles de Câmera para o Estágio MALL

    public func recenterInteriorCamera() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            interiorZoom = 0.55
            lastInteriorZoom = 0.55
            interiorPan = .zero
            lastInteriorPan = .zero
        }
    }

    public func zoomInInterior() {
        withAnimation(.easeInOut(duration: 0.2)) {
            let next = min(interiorZoom + 0.25, 3.0)
            interiorZoom = next
            lastInteriorZoom = next
        }
    }

    public func zoomOutInterior() {
        withAnimation(.easeInOut(duration: 0.2)) {
            let next = max(interiorZoom - 0.25, 0.35)
            interiorZoom = next
            lastInteriorZoom = next
        }
    }

    // MARK: - Controles de Câmera para o Estágio MAP (Apple Maps)

    public func recenterCityCamera(focusOnUser: Bool = false) {
        let targetCoordinate: CLLocationCoordinate2D
        if focusOnUser, let userLoc = UserLocationService.shared.userLocation {
            targetCoordinate = userLoc
        } else {
            targetCoordinate = mallCoordinate
        }

        cityCameraDistance = 750.0
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: targetCoordinate,
                    distance: cityCameraDistance,
                    heading: 0,
                    pitch: 0
                )
            )
        }
    }

    public func zoomInCity() {
        cityCameraDistance = max(cityCameraDistance * 0.65, 250.0)
        withAnimation(.easeInOut(duration: 0.2)) {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: mallCoordinate,
                    distance: cityCameraDistance,
                    heading: 0,
                    pitch: 0
                )
            )
        }
    }

    public func zoomOutCity() {
        cityCameraDistance = min(cityCameraDistance * 1.5, 25_000.0)
        withAnimation(.easeInOut(duration: 0.2)) {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: mallCoordinate,
                    distance: cityCameraDistance,
                    heading: 0,
                    pitch: 0
                )
            )
        }
    }

    // MARK: - Atualização de Distância e Tempo de Trânsito

    public func refreshUserDistanceAndETA() async {
        let service = UserLocationService.shared
        if let direct = service.directDistance(to: mallCoordinate) {
            userDistanceText = service.formatDistance(direct)
        }

        if let eta = await service.fetchDrivingETA(to: mallCoordinate) {
            self.rawETA = eta
            self.userDistanceText = service.formatDistance(eta.distance)
            self.userETAText = service.formatTravelTime(eta.travelTime)
        }
    }
}
