import Foundation

// MARK: - Caso de Uso: Carregamento e Parsing de Configuração de Shopping (SOLID - Single Responsibility)

@MainActor
public final class LoadMallConfigUseCase: Sendable {
    private let repository: any MallRepositoryProtocol

    public init(repository: any MallRepositoryProtocol) {
        self.repository = repository
    }

    /// Carrega o shopping a partir de um arquivo .json local do Bundle
    public func execute(bundleResourceName: String) async throws -> ShoppingMall {
        guard let url = Bundle.main.url(forResource: bundleResourceName, withExtension: "json") else {
            throw MallConfigError.fileNotFound(bundleResourceName)
        }

        let data = try Data(contentsOf: url)
        return try await execute(jsonData: data)
    }

    /// Carrega e sincroniza o shopping a partir de dados JSON brutos (usado pelo Bundle e pela API REST futura)
    public func execute(jsonData: Data) async throws -> ShoppingMall {
        let decoder = JSONDecoder()
        do {
            let dto = try decoder.decode(MallConfigDTO.self, from: jsonData)
            return try await repository.saveMall(from: dto)
        } catch {
            throw MallConfigError.decodingFailed(error)
        }
    }
}

public enum MallConfigError: LocalizedError, Sendable {
    case fileNotFound(String)
    case decodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Arquivo de configuração do shopping não encontrado: \(name).json"
        case .decodingFailed(let error):
            return "Falha ao decodificar configuração JSON do shopping: \(error.localizedDescription)"
        }
    }
}
