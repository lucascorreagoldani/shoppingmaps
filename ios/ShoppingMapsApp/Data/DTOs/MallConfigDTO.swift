import Foundation

// MARK: - DTOs de Configuração do Shopping (REST API & JSON)

public struct MallConfigDTO: Codable, Sendable, Identifiable {
    public let id: Int
    public let slug: String
    public let displayName: String
    public let country: String
    public let countryCode: String
    public let state: String
    public let stateCode: String
    public let city: String
    public let address: String
    public let postalCode: String
    public let coordinates: CoordinatesDTO
    public let canvas: CanvasDTO
    public let schemaVersion: String
    public let lastUpdated: String
    public let searchKeywords: [String]
    public let floors: [FloorLevelDTO]

    public struct CoordinatesDTO: Codable, Sendable {
        public let latitude: Double
        public let longitude: Double
    }

    public struct CanvasDTO: Codable, Sendable {
        public let width: Double
        public let height: Double
    }
}

public struct FloorLevelDTO: Codable, Sendable, Identifiable {
    public let id: UUID
    public let levelOrder: Int
    public let shortCode: String
    public let displayName: String
    public let subtitle: String
    public let stores: [StoreDTO]
}

public struct StoreDTO: Codable, Sendable, Identifiable {
    public let id: UUID
    public let storeNumber: String
    public let displayName: String
    public let category: String
    public let isAnchor: Bool
    public let mapX: Double
    public let mapY: Double
    public let width: Double
    public let height: Double
    public let openingHours: String
    public let phone: String
    public let tags: [String]
}

