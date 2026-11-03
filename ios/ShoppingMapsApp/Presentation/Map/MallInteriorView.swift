import SwiftUI

// MARK: - Visualização Interior do Shopping em Escala Ampliada (MALL-{andar})
// O mapa da cidade desaparece. A câmera se move livremente pelo interior do shopping,
// enquanto a carcaça, corredores e lojas permanecem estáticos no espaço com escala ampla e legível.

public struct MallInteriorView: View {
    @Bindable var viewModel: MallMapViewModel

    // Dimensões do Canvas Interior lidas dinamicamente da configuração do Shopping
    private var interiorWidth: CGFloat {
        CGFloat(viewModel.mall.mapWidth)
    }

    private var interiorHeight: CGFloat {
        CGFloat(viewModel.mall.mapHeight)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo neutro do interior (Ambiente climatizado do Mall)
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                // MARK: - Carcaça Estática do Shopping com Câmera Móvel
                ZStack {
                    MallInteriorFloorPlanView(
                        floor: viewModel.selectedFloor,
                        stores: viewModel.storesOnSelectedFloor,
                        selectedStore: viewModel.selectedStore,
                        width: interiorWidth,
                        height: interiorHeight,
                        onStoreSelected: { store in
                            viewModel.selectStore(store)
                        }
                    )
                }
                .frame(width: interiorWidth, height: interiorHeight)
                .scaleEffect(viewModel.interiorZoom)
                .offset(viewModel.interiorPan)
                .gesture(
                    SimultaneousGesture(
                        // Movimentação da Câmera pelo Interior (Pan)
                        DragGesture()
                            .onChanged { value in
                                viewModel.interiorPan = CGSize(
                                    width: viewModel.lastInteriorPan.width + value.translation.width,
                                    height: viewModel.lastInteriorPan.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                viewModel.lastInteriorPan = viewModel.interiorPan
                            },
                        // Zoom da Câmera pelo Interior (Pinch)
                        MagnifyGesture()
                            .onChanged { value in
                                let newZoom = viewModel.lastInteriorZoom * value.magnification
                                viewModel.interiorZoom = min(max(newZoom, 0.35), 3.0)
                            }
                            .onEnded { _ in
                                viewModel.lastInteriorZoom = viewModel.interiorZoom
                            }
                    )
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }
}

// MARK: - Planta Baixa Interna Detalhada com Corredores e Lojas Estáticas

private struct MallInteriorFloorPlanView: View {
    let floor: FloorLevel?
    let stores: [Store]
    let selectedStore: Store?
    let width: CGFloat
    let height: CGFloat
    let onStoreSelected: (Store) -> Void

    // Estrutura perimetral arquitetural
    private var buildingWidth: CGFloat { width - 160.0 }
    private var buildingHeight: CGFloat { height - 240.0 }

    var body: some View {
        ZStack {
            // MARK: - 1. Carcaça Externa do Prédio (Paredes Estruturais)
            RoundedRectangle(cornerRadius: 48)
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(width: buildingWidth, height: buildingHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 48)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 3.5)
                )
                .shadow(color: .black.opacity(0.16), radius: 30, y: 15)

            // MARK: - 2. Corredores de Circulação de Pedestres (Boulevard Waze Indoor)
            ZStack {
                // Corredor longitudinal amplo (Eixo Leste-Oeste)
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: buildingWidth - 60, height: 320)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.blue.opacity(0.12), lineWidth: 1.5)
                    )

                // Boulevard de acesso frontal (Conecta a Entrada Principal ao Átrio)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: 260, height: 360)
                    .offset(y: -180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.10), lineWidth: 1.5)
                    )

                // Átrio central circular (Vão das escadas rolantes e elevadores)
                Circle()
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: 300, height: 300)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.25), lineWidth: 2.5)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.cyan.opacity(0.20), lineWidth: 1.0)
                            .padding(12)
                    )

                // Núcleo de Conexão Vertical (Escadas Rolantes & Elevadores)
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.stairs")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.blue)

                        Image(systemName: "arrow.up.and.down.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.cyan)
                    }

                    Text("Átrio Central")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("Escadas Rolantes & Elevadores")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                // Identificadores Sutis de Alas no Piso
                HStack {
                    Text("ALA OESTE")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.25))
                        .tracking(3)
                        .padding(.leading, 80)

                    Spacer()

                    Text("ALA LESTE")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.25))
                        .tracking(3)
                        .padding(.trailing, 80)
                }
                .frame(width: buildingWidth - 100)
            }

            // MARK: - 3. Pórticos de Acesso
            // Entrada Principal (Madre Benvenuta)
            HStack(spacing: 6) {
                Image(systemName: "door.left.hand.open")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.cyan)
                Text("Entrada Principal • Av. Me. Benvenuta")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color(uiColor: .systemBackground))
            .clipShape(.capsule)
            .overlay(Capsule().stroke(Color.cyan, lineWidth: 1.5))
            .shadow(color: .cyan.opacity(0.35), radius: 8)
            .offset(y: -(buildingHeight / 2.0))

            // MARK: - 4. Blocos de Lojas Espaçosas no Interior
            ForEach(stores) { store in
                let isSelected = selectedStore?.id == store.id
                StoreInteriorBlockView(
                    store: store,
                    interiorWidth: width,
                    interiorHeight: height,
                    isSelected: isSelected
                ) {
                    onStoreSelected(store)
                }
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Bloco de Loja com Área Ampla e Legibilidade Confortável

private struct StoreInteriorBlockView: View {
    let store: Store
    let interiorWidth: CGFloat
    let interiorHeight: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    // Posicionamento exato baseado nas coordenadas de métrica arquitetural do Canvas
    private var posX: CGFloat {
        CGFloat(store.mapX) + (CGFloat(store.width) / 2.0) - (interiorWidth / 2.0)
    }

    private var posY: CGFloat {
        CGFloat(store.mapY) + (CGFloat(store.height) / 2.0) - (interiorHeight / 2.0)
    }

    private var blockWidth: CGFloat {
        CGFloat(store.width)
    }

    private var blockHeight: CGFloat {
        CGFloat(store.height)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Fundo com a cor da categoria
                RoundedRectangle(cornerRadius: store.isAnchor ? 16 : 10)
                    .fill(store.category.color.opacity(isSelected ? 0.40 : (store.isAnchor ? 0.22 : 0.15)))

                // Borda arquitetural
                RoundedRectangle(cornerRadius: store.isAnchor ? 16 : 10)
                    .stroke(
                        isSelected ? Color.blue : store.category.color.opacity(0.85),
                        lineWidth: isSelected ? 3.5 : 1.5
                    )

                // Conteúdo da Loja
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: store.category.iconName)
                            .font(.system(size: store.isAnchor ? 15 : 12, weight: .bold))
                            .foregroundStyle(store.category.color)

                        if store.isAnchor {
                            Text("ÂNCORA")
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(store.category.color.opacity(0.25))
                                .clipShape(.capsule)
                                .foregroundStyle(store.category.color)
                        }

                        Spacer()

                        Text(store.storeNumber)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    Text(store.name)
                        .font(.system(size: store.isAnchor ? 16 : 12, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    HStack {
                        Text(store.category.displayName)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Spacer()
                    }
                }
                .padding(store.isAnchor ? 12 : 8)
            }
            .frame(width: blockWidth, height: blockHeight)
            .shadow(
                color: isSelected ? Color.blue.opacity(0.45) : Color.black.opacity(0.08),
                radius: isSelected ? 10 : 3,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .offset(x: posX, y: posY)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
