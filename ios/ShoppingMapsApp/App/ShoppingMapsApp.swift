import SwiftUI
import SwiftData

@main
struct ShoppingMapsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ShoppingMall.self,
            FloorLevel.self,
            Store.self,
            NavigationNode.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Resiliência de Desenvolvimento: Se o schema foi alterado (ex: migração UUID -> Int),
            // remove o banco local antigo incompatível e recria o container limpo.
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)

            let walURL = storeURL.deletingPathExtension().appendingPathExtension("store-wal")
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("store-shm")
            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Não foi possível inicializar o ModelContainer do SwiftData: \(error)")
            }
        }
    }()

    @State private var isAppReady: Bool = false
    @State private var loadingStatus: String = "Localizando Shopping Villa Romana..."
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAppReady {
                    ContentView()
                        .transition(.opacity)
                } else {
                    SplashLoadingView(statusMessage: loadingStatus)
                        .transition(.opacity.combined(with: .scale(scale: 1.03)))
                }
            }
            .preferredColorScheme(themeManager.resolvedScheme)
            .modelContainer(sharedModelContainer)
            .task {
                themeManager.updateResolvedScheme()
                await bootstrapApp()
            }
        }
    }

    @MainActor
    private func bootstrapApp() async {
        let startTime = CFAbsoluteTimeGetCurrent()

        let repository = SwiftDataMallRepository(modelContext: sharedModelContainer.mainContext)
        let syncUseCase = SyncMallUseCase(repository: repository)

        do {
            loadingStatus = "Sincronizando mapas indoor e lojas..."
            let result = try await syncUseCase.execute(slug: "villa-romana-florianopolis")
            switch result {
            case .updated(let mall):
                print("✅ ShoppingMaps: Dados sincronizados para \(mall.name)")
            case .upToDate(let mall):
                print("⚡️ ShoppingMaps: Cache atualizado para \(mall.name)")
            case .offline(let mall, let error):
                print("📡 ShoppingMaps: Modo Offline para \(mall.name). (\(error.localizedDescription))")
            }
        } catch {
            print("⚠️ Erro na sincronização inicial do shopping: \(error)")
        }

        loadingStatus = "Tudo pronto!"
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        let minDisplayTime: Double = 0.85
        if elapsed < minDisplayTime {
            try? await Task.sleep(nanoseconds: UInt64((minDisplayTime - elapsed) * 1_000_000_000))
        }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
            isAppReady = true
        }
    }
}
