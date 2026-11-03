import Foundation

// MARK: - Zonas Arquiteturais do Shopping (Waze Indoor)

public enum MallZone: String, CaseIterable, Codable, Sendable, Identifiable {
    case mainEntrance = "main_entrance"
    case centralAtrium = "central_atrium"
    case westWing = "west_wing"
    case eastWing = "east_wing"
    case foodCourt = "food_court"
    case parkingAccess = "parking_access"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .mainEntrance: return "Entrada Principal"
        case .centralAtrium: return "Átrio Central & Escadas"
        case .westWing: return "Ala Oeste"
        case .eastWing: return "Ala Leste"
        case .foodCourt: return "Praça de Alimentação"
        case .parkingAccess: return "Acesso ao Estacionamento"
        }
    }

    public var iconName: String {
        switch self {
        case .mainEntrance: return "door.left.hand.open"
        case .centralAtrium: return "figure.stairs"
        case .westWing: return "arrow.left.square"
        case .eastWing: return "arrow.right.square"
        case .foodCourt: return "fork.knife"
        case .parkingAccess: return "car.fill"
        }
    }
}

// MARK: - Tipos de Implantação de Espaços

public enum StorePlacementType: String, Codable, Sendable {
    case anchor = "anchor"
    case satellite = "satellite"
    case kiosk = "kiosk"
    case restroom = "restroom"
    case service = "service"
    case verticalConnector = "vertical_connector"

    public var minWidth: Double {
        switch self {
        case .anchor: return 280.0
        case .satellite: return 140.0
        case .kiosk: return 80.0
        case .restroom, .service: return 100.0
        case .verticalConnector: return 120.0
        }
    }

    public var minHeight: Double {
        switch self {
        case .anchor: return 180.0
        case .satellite: return 120.0
        case .kiosk: return 70.0
        case .restroom, .service: return 90.0
        case .verticalConnector: return 120.0
        }
    }
}

// MARK: - Métricas de Escala Indoor do Canvas

public struct MallCanvasMetrics: Equatable, Hashable, Codable, Sendable {
    public var width: Double
    public var height: Double
    public var corridorWidth: Double
    public var initialZoom: Double
    public var minZoom: Double
    public var maxZoom: Double

    public init(
        width: Double = 2200.0,
        height: Double = 1300.0,
        corridorWidth: Double = 180.0,
        initialZoom: Double = 1.0,
        minZoom: Double = 0.5,
        maxZoom: Double = 3.5
    ) {
        self.width = width
        self.height = height
        self.corridorWidth = corridorWidth
        self.initialZoom = initialZoom
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
}

// MARK: - Estágios do Mapa (Compartilhado entre todos os tipos de mapas)

public enum MapStage: Equatable, Hashable, Codable, Sendable, Identifiable, CustomStringConvertible {
    /// Estágio 1: Visão da cidade pelo Apple Maps, mostrando o polígono do shopping ancorado na cidade
    case map

    /// Estágio 2: Visão arquitetural em grande escala focada no interior do shopping no andar especificado
    case mall(floorCode: String, zone: MallZone? = nil)

    public var id: String { rawValue }

    public var rawValue: String {
        switch self {
        case .map:
            return "MAP"
        case .mall(let floorCode, _):
            return "MALL-\(floorCode.uppercased())"
        }
    }

    public var description: String { rawValue }

    public init(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed == "MAP" {
            self = .map
        } else if trimmed.hasPrefix("MALL-") {
            let floor = String(trimmed.dropFirst(5))
            self = .mall(floorCode: floor.isEmpty ? "L1" : floor)
        } else {
            self = .map
        }
    }

    public var isMap: Bool {
        if case .map = self { return true }
        return false
    }

    public var isMall: Bool {
        if case .mall = self { return true }
        return false
    }

    public var activeFloorCode: String? {
        if case .mall(let code, _) = self { return code }
        return nil
    }

    public var activeZone: MallZone? {
        if case .mall(_, let zone) = self { return zone }
        return nil
    }
}
