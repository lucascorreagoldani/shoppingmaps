import Foundation

// MARK: - Contrato de Repositório (SOLID - Interface Segregation & Dependency Inversion)

@MainActor
public protocol MallRepositoryProtocol: Sendable {
    func fetchMalls() async throws -> [ShoppingMall]
    func fetchMall(bySlug slug: String) async throws -> ShoppingMall?
    func fetchMall(byId id: Int) async throws -> ShoppingMall?
    func saveMall(from dto: MallConfigDTO) async throws -> ShoppingMall
    func deleteMall(byId id: Int) async throws
    func searchStores(query: String, mallId: Int) async throws -> [Store]
}
