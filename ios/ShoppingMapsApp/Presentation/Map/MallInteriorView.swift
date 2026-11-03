import SwiftUI

// MARK: - Visualização Interior do Shopping em Escala Ampliada (MALL-{andar})
// O mapa da cidade desaparece. A câmera se move livremente pelo interior do shopping,
// enquanto a carcaça, corredores e lojas permanecem estáticos no espaço.

public struct MallInteriorView: View {
    @Bindable var viewModel: MallMapViewModel

    // Dimensões do Canvas Interior em Escala Espaçosa (1 metro é maior)
    private let interiorWidth: CGFloat = 1200
    private let interiorHeight: CGFloat = 620

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
                                viewModel.interiorZoom = min(max(newZoom, 0.6), 3.5)
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

    // Formato alongado do Villa Romana Shopping (~3.5:1)
    private var buildingWidth: CGFloat { width * 0.90 }
    private var buildingHeight: CGFloat { height * 0.70 }

    var body: some View {
        ZStack {
            // MARK: - 1. Carcaça Externa do Prédio (Paredes Estruturais)
            RoundedRectangle(cornerRadius: 36)
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(width: buildingWidth, height: buildingHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.18), radius: 24, y: 12)

            // MARK: - 2. Corredores de Circulação de Pedestres (Boulevard)
            ZStack {
                // Corredor longitudinal amplo
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: buildingWidth * 0.88, height: buildingHeight * 0.28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.blue.opacity(0.15), lineWidth: 1.5)
                    )

                // Átrio central circular (Vão das escadas rolantes e elevadores)
                Circle()
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: buildingHeight * 0.44, height: buildingHeight * 0.44)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.25), lineWidth: 2)
                    )

                // Ícone central discreto das escadas rolantes / conexões verticais
                VStack(spacing: 2) {
                    Image(systemName: "figure.stairs")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("Escadas & Elevador")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - 3. Pórtico Frontal de Entrada (Rua Santa Mônica)
            HStack(spacing: 6) {
                Image(systemName: "door.left.hand.open")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.cyan)
                Text("Entrada Principal • Madre Benvenuta")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(Color(uiColor: .systemBackground))
            .clipShape(.capsule)
            .overlay(Capsule().stroke(Color.cyan, lineWidth: 1.5))
            .shadow(color: .cyan.opacity(0.4), radius: 6)
            .offset(y: -buildingHeight * 0.50)

            // MARK: - 4. Blocos de Lojas Espaçosas no Interior
            ForEach(stores) { store in
                let isSelected = selectedStore?.id == store.id
                StoreInteriorBlockView(
                    store: store,
                    buildingWidth: buildingWidth,
                    buildingHeight: buildingHeight,
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
    let buildingWidth: CGFloat
    let buildingHeight: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    // Mapeamento proporcional de coordenadas do modelo (0..1000, 0..700) para a carcaça interna
    private var posX: CGFloat {
        let ratio = CGFloat(store.mapX) / 1000.0
        return (ratio * (buildingWidth - 120)) + 60 - (buildingWidth / 2.0)
    }

    private var posY: CGFloat {
        let ratio = CGFloat(store.mapY) / 700.0
        return (ratio * (buildingHeight - 90)) + 45 - (buildingHeight / 2.0)
    }

    private var blockWidth: CGFloat {
        max(CGFloat(store.width) * (buildingWidth / 1000.0), 65)
    }

    private var blockHeight: CGFloat {
        max(CGFloat(store.height) * (buildingHeight / 700.0), 45)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Fundo com a cor da categoria
                RoundedRectangle(cornerRadius: store.isAnchor ? 12 : 8)
                    .fill(store.category.color.opacity(isSelected ? 0.45 : (store.isAnchor ? 0.28 : 0.20)))

                // Borda
                RoundedRectangle(cornerRadius: store.isAnchor ? 12 : 8)
                    .stroke(
                        isSelected ? Color.white : store.category.color.opacity(0.85),
                        lineWidth: isSelected ? 3 : 1.5
                    )

                // Conteúdo da Loja
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        Image(systemName: store.category.iconName)
                            .font(.system(size: store.isAnchor ? 12 : 10, weight: .bold))
                            .foregroundStyle(store.category.color)

                        if store.isAnchor {
                            Text("ÂNCORA")
                                .font(.system(size: 7, weight: .black))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(store.category.color.opacity(0.25))
                                .clipShape(.capsule)
                                .foregroundStyle(store.category.color)
                        }
                    }

                    Text(store.name)
                        .font(.system(size: store.isAnchor ? 11 : 9, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 4)

                    Text(store.storeNumber)
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }
            .frame(width: blockWidth, height: blockHeight)
            .shadow(
                color: isSelected ? Color.blue.opacity(0.5) : Color.black.opacity(0.08),
                radius: isSelected ? 8 : 2,
                y: isSelected ? 2 : 1
            )
        }
        .buttonStyle(.plain)
        .offset(x: posX, y: posY)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

