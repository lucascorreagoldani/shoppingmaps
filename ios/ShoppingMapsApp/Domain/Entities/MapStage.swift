import Foundation

// MARK: - Estágios do Mapa (Compartilhado entre todos os tipos de mapas)

public enum MapStage: Equatable, Hashable, Codable, Sendable, Identifiable, CustomStringConvertible {
    /// Estágio 1: Visão da cidade pelo Apple Maps, mostrando a circunferência e contorno do shopping em destaque
    case map

    /// Estágio 2: Visão focada no interior do shopping no andar especificado (ex: "G", "L1", "L2", "L3")
    case mall(floorCode: String)

    public var id: String { rawValue }

    public var rawValue: String {
        switch self {
        case .map:
            return "MAP"
        case .mall(let floorCode):
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
        if case .mall(let code) = self { return code }
        return nil
    }
}

