import SwiftUI
import MapKit

public struct IndoorMapView: View {
    @State private var viewModel: MallMapViewModel
    @State private var showingThemePreferences: Bool = false
    @Environment(\.dismiss) private var dismiss

    public init(
        mall: ShoppingMall,
        initialStage: MapStage = .map,
        initialFloorCode: String? = nil
    ) {
        _viewModel = State(initialValue: MallMapViewModel(
            mall: mall,
            initialStage: initialStage,
            initialFloorCode: initialFloorCode
        ))
    }

    public var body: some View {
        ZStack {
            // MARK: - Alternância entre os Estágios (MAP vs MALL-{andar})
            if viewModel.stage.isMap {
                // MARK: ==========================================
                // ESTÁGIO 1: MAP (Apple Maps da Cidade com Perímetro do Shopping em Destaque)
                // ================================================
                CityMapStageView(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                // MARK: ==========================================
                // ESTÁGIO 2: MALL-{andar} (Foco no Interior do Shopping em Escala Ampliada)
                // ================================================
                MallInteriorStageView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Text(viewModel.mall.name)
                        .font(.subheadline.weight(.semibold))

                    // Badge do Estágio Atual
                    Text(viewModel.stage.rawValue)
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(viewModel.stage.isMall ? Color.blue : Color.secondary.opacity(0.2))
                        .foregroundStyle(viewModel.stage.isMall ? .white : .primary)
                        .clipShape(.capsule)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingThemePreferences = true
                } label: {
                    Image(systemName: ThemeManager.shared.mode.iconName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(7)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(.circle)
                }
            }
        }
        .sheet(isPresented: $showingThemePreferences) {
            ThemePreferencesSheetView()
        }
    }
}

// MARK: - ESTÁGIO 1: CityMapStageView (MAP)

private struct CityMapStageView: View {
    @Bindable var viewModel: MallMapViewModel
    @State private var isMapReady: Bool = false
    @State private var showingNavigationSheet: Bool = false
    @State private var userLocationService = UserLocationService.shared

    var body: some View {
        ZStack {
            // 1. Apple Maps Nativo carregado suavemente com Polígono Real no Solo
            if isMapReady {
                Map(position: $viewModel.cameraPosition) {
                    // Ponto azul nativo do usuário no mapa da cidade
                    UserAnnotation()

                    // Contorno do shopping no solo (MapPolygon): Ancorado na geografia real.
                    // Quando o usuário afasta a câmera (zoom out), ele reduz proporcionalmente com a ilha!
                    MapPolygon(coordinates: viewModel.mallFootprint)
                        .foregroundStyle(Color.blue.opacity(0.32))
                        .stroke(Color.cyan, lineWidth: 2.5)

                    // Marcador adaptativo rigorosamente contido nos limites do polígono do shopping
                    // 1. Passamos "" como título para evitar que o MapKit desenhe o texto cinza redundante no chão
                    // 2. Ancorado no .center do polígono geográfico
                    // 3. Quando o usuário dá zoom out (> 1400m), colapsa para um ícone compacto que cabe no polígono
                    // 4. Quando aproximado (<= 1400m), exibe a pílula com escala proporcional adaptativa
                    Annotation(
                        "",
                        coordinate: viewModel.mallCoordinate,
                        anchor: .center
                    ) {
                        Button {
                            viewModel.enterMall()
                        } label: {
                            if viewModel.cityCameraDistance > 1400.0 {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.blue)
                                    .clipShape(.circle)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "building.2.crop.circle.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.cyan)
                                    Text(viewModel.mall.name)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.92))
                                .clipShape(.capsule)
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.8), lineWidth: 1.2))
                                .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
                                .scaleEffect(viewModel.cityAnnotationScale)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                .mapControlVisibility(.hidden)
                .ignoresSafeArea()
                .transition(.opacity)
            } else {
                // Background suave que evita o flash cinza do MapKit e o congelamento da animação
                ZStack {
                    Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                    VStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.regular)
                        Text("Carregando mapa...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 2. Controles Flutuantes Modernos de Câmera e Localização
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    // Botão 1: Ir até o Shopping (Centraliza no Villa Romana)
                    Button {
                        viewModel.recenterCityCamera(focusOnUser: false)
                    } label: {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.cyan)
                            .frame(width: 44, height: 44)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                    }

                    // Botão 2: Ir até a Minha Localização
                    Button {
                        if userLocationService.userLocation != nil {
                            viewModel.recenterCityCamera(focusOnUser: true)
                        } else {
                            userLocationService.requestAuthorization()
                        }
                    } label: {
                        Image(systemName: userLocationService.userLocation != nil ? "location.fill" : "location")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(userLocationService.userLocation != nil ? Color.blue : Color.secondary)
                            .frame(width: 44, height: 44)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(.rect(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                    }

                    // Pílula vertical unificada de Zoom (+ e -)
                    VStack(spacing: 0) {
                        Button {
                            viewModel.zoomInCity()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 40)
                        }

                        Divider()
                            .frame(width: 28)

                        Button {
                            viewModel.zoomOutCity()
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 40)
                        }
                    }
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                }
                .padding(.trailing, 16)
                .padding(.top, 70)
                Spacer().frame(width: 0)
            }

            // 3. Card Inferior de Acesso ao Shopping com Distância e Rotas Externas
            VStack {
                Spacer()

                VStack(spacing: 14) {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "building.2.fill")
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.mall.name)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                            Text(viewModel.mall.address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }

                    // Métricas de Tempo e Distância em Tempo Real
                    HStack(spacing: 10) {
                        if let eta = viewModel.userETAText, let dist = viewModel.userDistanceText {
                            HStack(spacing: 5) {
                                Image(systemName: "car.fill")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.blue)
                                Text(eta)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.primary)
                                Text("de carro")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.10))
                            .clipShape(.capsule)

                            HStack(spacing: 5) {
                                Image(systemName: "location.fill")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.secondary)
                                Text(dist)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(.capsule)
                        } else {
                            Button {
                                userLocationService.requestAuthorization()
                                Task {
                                    await viewModel.refreshUserDistanceAndETA()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.caption)
                                    Text("Calcular distância até o shopping")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(.blue)
                                .padding(.vertical, 2)
                            }
                        }
                        Spacer()
                    }

                    // Botões de Ação: Como Chegar (Externo) e Entrar (Indoor)
                    HStack(spacing: 10) {
                        // Botão Como Chegar (Waze, Apple Maps, Google Maps)
                        Button {
                            showingNavigationSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .font(.subheadline)
                                Text("Como Chegar")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(.rect(cornerRadius: 16))
                        }

                        // Botão Entrar no Shopping
                        Button {
                            viewModel.enterMall(floorCode: "L1")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "door.left.hand.open")
                                    .font(.subheadline)
                                Text("Entrar (MALL-L1)")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
                        }
                    }
                }
                .padding(18)
                .background(Color(uiColor: .systemBackground))
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(color: .black.opacity(0.15), radius: 14, y: 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .task {
            if !isMapReady {
                // Aguarda 80ms para a animação de transição da tela completar sem drop de frames
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.easeIn(duration: 0.2)) {
                    isMapReady = true
                }
            }
            await viewModel.refreshUserDistanceAndETA()
        }
        .sheet(isPresented: $showingNavigationSheet) {
            ExternalNavigationSheetView(
                destination: viewModel.mallCoordinate,
                destinationName: viewModel.mall.name,
                address: viewModel.mall.address,
                etaInfo: viewModel.rawETA
            )
        }
    }
}

// MARK: - ESTÁGIO 2: MallInteriorStageView (MALL-{andar})

private struct MallInteriorStageView: View {
    @Bindable var viewModel: MallMapViewModel

    var body: some View {
        ZStack {
            // 1. Carcaça Interior do Shopping com Escala Ampliada e Câmera Móvel
            MallInteriorView(viewModel: viewModel)

            // 2. Barra Superior com Botão de Voltar para Cidade (MAP) e Indicador de Andar
            VStack {
                HStack(spacing: 10) {
                    // Botão Voltar para o Mapa da Cidade
                    Button {
                        viewModel.exitToCityMap()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                                .font(.caption.weight(.bold))
                            Text("Ver no Mapa (MAP)")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .systemBackground).opacity(0.95))
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    }

                    Spacer()

                    // Indicador do Piso Ativo
                    Text(viewModel.selectedFloor?.name ?? "Interior")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .systemBackground).opacity(0.95))
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                Spacer()
            }

            // 3. Controles Flutuantes da Direita (Floor Picker & Câmera do Interior)
            HStack {
                Spacer()

                VStack(spacing: 14) {
                    // Seletor vertical de andares (G, L1, L2, L3)
                    FloorPickerView(viewModel: viewModel)

                    // Controles de Câmera do Interior
                    VStack(spacing: 8) {
                        Button {
                            viewModel.recenterInteriorCamera()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(.rect(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                        }

                        Button {
                            viewModel.zoomInInterior()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 40)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(.rect(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                        }

                        Button {
                            viewModel.zoomOutInterior()
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 40)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(.rect(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 70)

                Spacer().frame(width: 0)
            }

            // 4. Card Flutuante de Loja Selecionada
            VStack {
                Spacer()

                if let store = viewModel.selectedStore {
                    StoreQuickPreviewCardView(
                        store: store,
                        onDismiss: {
                            viewModel.clearSelection()
                        },
                        onRouteRequested: {}
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}
