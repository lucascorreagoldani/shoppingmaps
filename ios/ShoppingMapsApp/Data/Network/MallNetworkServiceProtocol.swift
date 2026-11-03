import Foundation

// MARK: - Contrato de Serviço de Rede para Shoppings (SOLID - Interface Segregation)

public protocol MallNetworkServiceProtocol: Sendable {
    /// Busca a lista de shoppings disponíveis (sumário)
    func fetchAvailableMalls() async throws -> [MallSummaryDTO]

    /// Busca o arquivo completo de configuração de um shopping pelo seu slug
    func fetchMallConfig(slug: String) async throws -> MallConfigDTO

    /// Verifica a versão remota mais recente da configuração do shopping
    func checkMallVersion(slug: String) async throws -> Int
}

// MARK: - DTO Resumido para Listagem Rápida

public struct MallSummaryDTO: Codable, Sendable, Identifiable {
    public let id: Int
    public let slug: String
    public let displayName: String
    public let city: String
    public let stateCode: String
    public let schemaVersion: Int
    public let totalFloors: Int
    public let totalStores: Int

    public init(
        id: Int,
        slug: String,
        displayName: String,
        city: String,
        stateCode: String,
        schemaVersion: Int,
        totalFloors: Int,
        totalStores: Int
    ) {
        self.id = id
        self.slug = slug
        self.displayName = displayName
        self.city = city
        self.stateCode = stateCode
        self.schemaVersion = schemaVersion
        self.totalFloors = totalFloors
        self.totalStores = totalStores
    }
}

