import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

// MARK: - Destino de Navegação Tipado (Lazy & Alta Performance)

public enum MapNavigationTarget: Hashable, Sendable {
    case cityMap(mallId: Int)
    case floor(mallId: Int, floorCode: String)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var malls: [ShoppingMall]
    @State private var isSyncing: Bool = false
    @State private var syncStatusMessage: String?
    @State private var showingThemePreferences: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let mall = malls.first {
                        MallHeaderCardView(mall: mall, syncStatus: syncStatusMessage)

                        // Botão de Entrada Direta no Mapa da Cidade (MAP)
                        NavigationLink(value: MapNavigationTarget.cityMap(mallId: mall.id)) {
                            HStack(spacing: 12) {
                                Image(systemName: "map.fill")
                                    .font(.title3.weight(.bold))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Abrir Mapa da Região (MAP)")
                                        .font(.headline.weight(.bold))
                                    Text("Visão com contorno no Apple Maps")
                                        .font(.caption)
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: .blue.opacity(0.35), radius: 8, y: 4)
                        }

                        FloorsOverviewSection(mall: mall)
                    } else {
                        ContentUnavailableView(
                            "Carregando Shopping...",
                            systemImage: "map.fill",
                            description: Text("Sincronizando o mapa indoor do Villa Romana Florianópolis.")
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("ShoppingMaps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingThemePreferences = true
                    } label: {
                        Image(systemName: ThemeManager.shared.mode.iconName)
                            .font(.body.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingThemePreferences) {
                ThemePreferencesSheetView()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable {
                await syncMallData()
            }
            .navigationDestination(for: MapNavigationTarget.self) { target in
                switch target {
                case .cityMap(let mallId):
                    if let mall = malls.first(where: { $0.id == mallId }) {
                        IndoorMapView(mall: mall, initialStage: .map)
                    }
                case .floor(let mallId, let floorCode):
                    if let mall = malls.first(where: { $0.id == mallId }) {
                        IndoorMapView(
                            mall: mall,
                            initialStage: .mall(floorCode: floorCode),
                            initialFloorCode: floorCode
                        )
                    }
                }
            }
        }
    }

    private func syncMallData() async {
        isSyncing = true
        defer { isSyncing = false }
        let repository = SwiftDataMallRepository(modelContext: modelContext)
        let syncUseCase = SyncMallUseCase(repository: repository)
        do {
            let result = try await syncUseCase.execute(slug: "villa-romana-florianopolis")
            switch result {
            case .updated:
                syncStatusMessage = "Atualizado agora"
            case .upToDate:
                syncStatusMessage = "Sincronizado"
            case .offline:
                syncStatusMessage = "Offline (Cache local)"
            }
        } catch {
            syncStatusMessage = "Offline"
        }
    }
}

// MARK: - Subviews Modulares

private struct MallHeaderCardView: View {
    let mall: ShoppingMall
    let syncStatus: String?

    var totalStoresCount: Int {
        mall.floors.reduce(0) { $0 + $1.stores.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.85), .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.title2)
                        Text("Florianópolis • SC")
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        if let syncStatus {
                            Text(syncStatus)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.25))
                                .clipShape(.capsule)
                        }
                    }
                    .foregroundStyle(.white.opacity(0.9))

                    Text(mall.name)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)

                    Text(mall.address)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(20)
            }
            .clipShape(.rect(cornerRadius: 24))

            HStack(spacing: 12) {
                StatBadgeView(
                    icon: "square.stack.3d.up.fill",
                    title: "Andares",
                    value: mall.floors.count.formatted(.number)
                )

                StatBadgeView(
                    icon: "bag.fill",
                    title: "Lojas Mapeadas",
                    value: totalStoresCount.formatted(.number)
                )

                StatBadgeView(
                    icon: "location.fill",
                    title: "Status",
                    value: "Online"
                )
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 28))
    }
}

private struct StatBadgeView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

private struct FloorsOverviewSection: View {
    let mall: ShoppingMall

    var sortedFloors: [FloorLevel] {
        mall.floors.sorted { $0.levelOrder > $1.levelOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pisos do Shopping")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(sortedFloors) { floor in
                NavigationLink(value: MapNavigationTarget.floor(mallId: mall.id, floorCode: floor.shortCode)) {
                    FloorRowCardView(floor: floor)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct FloorRowCardView: View {
    let floor: FloorLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(floor.shortCode)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(floor.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(floor.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(floor.stores.count.formatted(.number)) lojas")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(.capsule)
            }

            // Preview das lojas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(floor.stores.prefix(4)) { store in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(store.category.color)
                                .frame(width: 8, height: 8)
                            Text(store.name)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(.capsule)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ShoppingMall.self, FloorLevel.self, Store.self, NavigationNode.self], inMemory: true)
}
