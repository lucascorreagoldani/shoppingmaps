import Foundation
import SwiftData
import SwiftUI

// MARK: - Modelo de Loja / POI

@Model
public final class Store {
    public var id: UUID = UUID()
    public var name: String = ""
    public var category: StoreCategory = StoreCategory.apparel
    public var storeNumber: String = ""
    public var mapX: Double = 0.0
    public var mapY: Double = 0.0
    public var width: Double = 80.0
    public var height: Double = 60.0
    public var openingHours: String = "10:00 às 22:00"
    public var phone: String = ""
    public var tags: String = ""
    public var isAnchor: Bool = false

    public var floor: FloorLevel?

    public init(
        id: UUID = UUID(),
        name: String,
        category: StoreCategory = .apparel,
        storeNumber: String,
        mapX: Double,
        mapY: Double,
        width: Double = 80.0,
        height: Double = 60.0,
        openingHours: String = "10:00 às 22:00",
        phone: String = "",
        tags: String = "",
        isAnchor: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.storeNumber = storeNumber
        self.mapX = mapX
        self.mapY = mapY
        self.width = width
        self.height = height
        self.openingHours = openingHours
        self.phone = phone
        self.tags = tags
        self.isAnchor = isAnchor
    }
}

// MARK: - Nós de Navegação (Walkable Corridors)

@Model
public final class NavigationNode {
    public var id: UUID = UUID()
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var label: String = ""
    public var isWalkable: Bool = true
    public var connectedNodeIds: [UUID] = []

    public var floor: FloorLevel?

    public init(
        id: UUID = UUID(),
        x: Double,
        y: Double,
        label: String = "",
        isWalkable: Bool = true,
        connectedNodeIds: [UUID] = []
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.label = label
        self.isWalkable = isWalkable
        self.connectedNodeIds = connectedNodeIds
    }
}

// MARK: - Piso / Andar

@Model
public final class FloorLevel {
    public var id: UUID = UUID()
    public var levelOrder: Int = 0
    public var name: String = ""
    public var shortCode: String = ""
    public var subtitle: String = ""

    public var mall: ShoppingMall?

    @Relationship(deleteRule: .cascade, inverse: \Store.floor)
    public var stores: [Store] = []

    @Relationship(deleteRule: .cascade, inverse: \NavigationNode.floor)
    public var walkableNodes: [NavigationNode] = []

    public init(
        id: UUID = UUID(),
        levelOrder: Int,
        name: String,
        shortCode: String,
        subtitle: String = ""
    ) {
        self.id = id
        self.levelOrder = levelOrder
        self.name = name
        self.shortCode = shortCode
        self.subtitle = subtitle
    }
}

// MARK: - Shopping Mall

@Model
public final class ShoppingMall {
    public var id: Int = 1
    public var slug: String = ""
    public var name: String = ""
    public var country: String = "Brasil"
    public var countryCode: String = "BR"
    public var state: String = "Santa Catarina"
    public var stateCode: String = "SC"
    public var city: String = "Florianópolis"
    public var address: String = ""
    public var postalCode: String = ""
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var mapWidth: Double = 1000.0
    public var mapHeight: Double = 700.0
    public var schemaVersion: String = "1.0.0"
    public var lastUpdated: String = ""
    public var searchKeywordsRaw: String = ""

    @Relationship(deleteRule: .cascade, inverse: \FloorLevel.mall)
    public var floors: [FloorLevel] = []

    public var searchKeywords: [String] {
        get {
            searchKeywordsRaw.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        set {
            searchKeywordsRaw = newValue.joined(separator: ",")
        }
    }

    public init(
        id: Int = 1,
        slug: String,
        name: String,
        country: String = "Brasil",
        countryCode: String = "BR",
        state: String,
        stateCode: String,
        city: String,
        address: String,
        postalCode: String = "",
        latitude: Double,
        longitude: Double,
        mapWidth: Double = 1000.0,
        mapHeight: Double = 700.0,
        schemaVersion: String = "1.0.0",
        lastUpdated: String = "",
        searchKeywords: [String] = []
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.country = country
        self.countryCode = countryCode
        self.state = state
        self.stateCode = stateCode
        self.city = city
        self.address = address
        self.postalCode = postalCode
        self.latitude = latitude
        self.longitude = longitude
        self.mapWidth = mapWidth
        self.mapHeight = mapHeight
        self.schemaVersion = schemaVersion
        self.lastUpdated = lastUpdated
        self.searchKeywordsRaw = searchKeywords.joined(separator: ",")
    }
}

