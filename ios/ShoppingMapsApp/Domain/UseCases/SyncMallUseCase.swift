import Foundation

// MARK: - Caso de Uso de Sincronização Remota Offline-First (Clean Architecture)

@MainActor
public final class SyncMallUseCase: Sendable {
    private let repository: any MallRepositoryProtocol
    private let networkService: any MallNetworkServiceProtocol

    public init(
        repository: any MallRepositoryProtocol,
        networkService: any MallNetworkServiceProtocol = URLSessionMallNetworkService()
    ) {
        self.repository = repository
        self.networkService = networkService
    }

    /// Executa a sincronização do shopping especificado com política estrita Offline-First
    @discardableResult
    public func execute(slug: String = "villa-romana-florianopolis") async throws -> SyncResult {
        // 1. Busca no cache local primeiro
        let localMall = try await repository.fetchMall(bySlug: slug)

        // 2. Se não existir localmente no banco, tenta semente inicial do Bundle
        if localMall == nil {
            let loadLocal = LoadMallConfigUseCase(repository: repository)
            _ = try? await loadLocal.execute(bundleResourceName: "brazil-santacatarina-florianopolis-villaromanashopping")
        }

        // 3. Tenta buscar a versão remota na API REST
        do {
            let remoteDTO = try await networkService.fetchMallConfig(slug: slug)

            // Se já tínhamos o shopping localmente, comparamos versão e data
            if let currentLocal = try await repository.fetchMall(bySlug: slug) {
                let shouldUpdate = remoteDTO.schemaVersion > currentLocal.schemaVersion ||
                                   remoteDTO.lastUpdated != currentLocal.lastUpdated

                if shouldUpdate {
                    let updatedMall = try await repository.saveMall(from: remoteDTO)
                    return .updated(updatedMall)
                } else {
                    return .upToDate(currentLocal)
                }
            } else {
                // Primeira inserção a partir da rede
                let savedMall = try await repository.saveMall(from: remoteDTO)
                return .updated(savedMall)
            }
        } catch {
            // Em caso de falha de conexão, usa o cache local com segurança
            if let fallbackLocal = try await repository.fetchMall(bySlug: slug) {
                return .offline(fallbackLocal, error: error)
            }
            throw error
        }
    }
}

// MARK: - Resultado da Sincronização

@MainActor
public enum SyncResult {
    case updated(ShoppingMall)
    case upToDate(ShoppingMall)
    case offline(ShoppingMall, error: Error)

    public var mall: ShoppingMall {
        switch self {
        case .updated(let mall), .upToDate(let mall), .offline(let mall, _):
            return mall
        }
    }

    public var isOffline: Bool {
        if case .offline = self { return true }
        return false
    }
}
