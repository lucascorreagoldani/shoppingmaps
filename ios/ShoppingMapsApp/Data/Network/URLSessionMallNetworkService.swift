import Foundation

// MARK: - Implementação do Serviço de Rede com URLSession e Fallback Resiliente

public final class URLSessionMallNetworkService: MallNetworkServiceProtocol, @unchecked Sendable {
    private let baseURL: URL?
    private let session: URLSession

    public init(
        baseURL: URL? = nil,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchAvailableMalls() async throws -> [MallSummaryDTO] {
        if let baseURL {
            let url = baseURL.appendingPathComponent("malls")
            do {
                let (data, response) = try await session.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return try JSONDecoder().decode([MallSummaryDTO].self, from: data)
            } catch {
                // Em caso de falha de conexão, recorre ao sumário local embutido
                return localFallbackSummary()
            }
        } else {
            // Modo local / Mock de desenvolvimento
            return localFallbackSummary()
        }
    }

    public func fetchMallConfig(slug: String) async throws -> MallConfigDTO {
        if let baseURL {
            let url = baseURL.appendingPathComponent("malls").appendingPathComponent(slug)
            do {
                let (data, response) = try await session.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return try JSONDecoder().decode(MallConfigDTO.self, from: data)
            } catch {
                // Recorre ao arquivo de configuração local do Bundle
                return try loadLocalBundleConfig(slug: slug)
            }
        } else {
            // Sem endpoint remoto configurado: lê diretamente do pacote local
            return try loadLocalBundleConfig(slug: slug)
        }
    }

    public func checkMallVersion(slug: String) async throws -> Int {
        if let baseURL {
            let url = baseURL.appendingPathComponent("malls").appendingPathComponent(slug).appendingPathComponent("version")
            do {
                let (data, response) = try await session.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return 1
                }
                struct VersionResponse: Codable {
                    let version: Int
                }
                let versionData = try JSONDecoder().decode(VersionResponse.self, from: data)
                return versionData.version
            } catch {
                return 1
            }
        }
        return 1
    }

    // MARK: - Helpers de Fallback Local

    private func localFallbackSummary() -> [MallSummaryDTO] {
        [
            MallSummaryDTO(
                id: 1,
                slug: "villa-romana-florianopolis",
                displayName: "Shopping Villa Romana",
                city: "Florianópolis",
                stateCode: "SC",
                schemaVersion: 1,
                totalFloors: 4,
                totalStores: 24
            )
        ]
    }

    private func loadLocalBundleConfig(slug: String) throws -> MallConfigDTO {
        // Mapeia o slug para o arquivo padrão {country}-{state}-{city}-{name}.json
        let resourceName: String
        switch slug {
        case "villa-romana-florianopolis":
            resourceName = "brazil-santacatarina-florianopolis-villaromanashopping"
        default:
            resourceName = slug
        }

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw NetworkError.resourceNotFound(resourceName)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(MallConfigDTO.self, from: data)
    }
}

// MARK: - Erros de Rede

public enum NetworkError: LocalizedError, Sendable {
    case invalidResponse
    case resourceNotFound(String)
    case noConnection

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Resposta inválida ou não autorizada do servidor."
        case .resourceNotFound(let resource):
            return "Recurso '\(resource)' não foi encontrado localmente nem remotamente."
        case .noConnection:
            return "Sem conexão com a internet."
        }
    }
}

