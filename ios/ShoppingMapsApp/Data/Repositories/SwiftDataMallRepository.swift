import Foundation
import SwiftData

@MainActor
public final class SwiftDataMallRepository: MallRepositoryProtocol {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchMalls() async throws -> [ShoppingMall] {
        let descriptor = FetchDescriptor<ShoppingMall>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchMall(bySlug slug: String) async throws -> ShoppingMall? {
        var descriptor = FetchDescriptor<ShoppingMall>(
            predicate: #Predicate { $0.slug == slug }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    public func fetchMall(byId id: Int) async throws -> ShoppingMall? {
        var descriptor = FetchDescriptor<ShoppingMall>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    public func saveMall(from dto: MallConfigDTO) async throws -> ShoppingMall {
        // Se já existe pelo id ou slug, remove o antigo para atualização limpa
        var existing = try await fetchMall(byId: dto.id)
        if existing == nil {
            existing = try await fetchMall(bySlug: dto.slug)
        }
        if let existing {
            modelContext.delete(existing)
        }

        let mall = ShoppingMall(
            id: dto.id,
            slug: dto.slug,
            name: dto.displayName,
            country: dto.country,
            countryCode: dto.countryCode,
            state: dto.state,
            stateCode: dto.stateCode,
            city: dto.city,
            address: dto.address,
            postalCode: dto.postalCode,
            latitude: dto.coordinates.latitude,
            longitude: dto.coordinates.longitude,
            mapWidth: dto.canvas.width,
            mapHeight: dto.canvas.height,
            schemaVersion: dto.schemaVersion,
            lastUpdated: dto.lastUpdated,
            searchKeywords: dto.searchKeywords
        )
        modelContext.insert(mall)

        for floorDTO in dto.floors {
            let floor = FloorLevel(
                id: floorDTO.id,
                levelOrder: floorDTO.levelOrder,
                name: floorDTO.displayName,
                shortCode: floorDTO.shortCode,
                subtitle: floorDTO.subtitle
            )
            floor.mall = mall
            modelContext.insert(floor)

            for storeDTO in floorDTO.stores {
                let category = StoreCategory(rawValue: storeDTO.category) ?? .services
                let store = Store(
                    id: storeDTO.id,
                    name: storeDTO.displayName,
                    category: category,
                    storeNumber: storeDTO.storeNumber,
                    mapX: storeDTO.mapX,
                    mapY: storeDTO.mapY,
                    width: storeDTO.width,
                    height: storeDTO.height,
                    openingHours: storeDTO.openingHours,
                    phone: storeDTO.phone,
                    tags: storeDTO.tags.joined(separator: " "),
                    isAnchor: storeDTO.isAnchor
                )
                store.floor = floor
                modelContext.insert(store)
            }
        }

        try modelContext.save()
        return mall
    }

    public func deleteMall(byId id: Int) async throws {
        if let mall = try await fetchMall(byId: id) {
            modelContext.delete(mall)
            try modelContext.save()
        }
    }

    public func searchStores(query: String, mallId: Int) async throws -> [Store] {
        guard let mall = try await fetchMall(byId: mallId) else { return [] }
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if cleanQuery.isEmpty {
            return mall.floors.flatMap(\.stores)
        }

        return mall.floors.flatMap(\.stores).filter { store in
            store.name.localizedStandardContains(cleanQuery) ||
            store.tags.localizedStandardContains(cleanQuery) ||
            store.category.displayName.localizedStandardContains(cleanQuery) ||
            store.storeNumber.localizedStandardContains(cleanQuery)
        }
    }
}

