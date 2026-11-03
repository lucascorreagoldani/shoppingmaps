import SwiftUI

// MARK: - Planta Baixa 2D Arquitetural e Limpa do Villa Romana Shopping
// Renderizada estaticamente sobre as coordenadas geográficas reais do shopping no Apple Maps

public struct MallFloor2DPlanView: View {
    let floor: FloorLevel?
    let stores: [Store]
    let selectedStore: Store?
    let onStoreSelected: (Store) -> Void

    // Dimensões proporcionais ao edifício real do Villa Romana (~280m x 80m)
    private let planWidth: CGFloat = 340
    private let planHeight: CGFloat = 110

    public var body: some View {
        ZStack {
            // MARK: - 1. Contorno Estrutural do Shopping (Formato Real do Terreno)
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.18, green: 0.22, blue: 0.28).opacity(0.92))
                .frame(width: planWidth, height: planHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 10, y: 5)

            // MARK: - 2. Corredores Internos (Boulevard Central)
            Path { path in
                // Corredor longitudinal por onde os pedestres transitam
                path.addRoundedRect(
                    in: CGRect(x: 20, y: planHeight * 0.40, width: planWidth - 40, height: planHeight * 0.22),
                    cornerSize: CGSize(width: 8, height: 8)
                )
                // Átrio central onde ficam escadas rolantes e elevadores
                path.addEllipse(in: CGRect(x: planWidth * 0.45, y: planHeight * 0.32, width: 34, height: 34))
            }
            .fill(Color.white.opacity(0.12))

            // Textura sutil do piso
            Path { path in
                path.move(to: CGPoint(x: 25, y: planHeight * 0.51))
                path.addLine(to: CGPoint(x: planWidth - 25, y: planHeight * 0.51))
            }
            .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

            // MARK: - 3. Pórtico Frontal de Entrada (Rua Santa Mônica)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.cyan)
                .frame(width: 50, height: 6)
                .offset(y: -planHeight * 0.50 - 2)
                .shadow(color: .cyan.opacity(0.8), radius: 4)

            // MARK: - 4. Blocos de Lojas do Piso Selecionado (2D Limpo)
            ForEach(stores) { store in
                let isSelected = selectedStore?.id == store.id
                Store2DBlockItemView(
                    store: store,
                    parentWidth: planWidth,
                    parentHeight: planHeight,
                    isSelected: isSelected
                ) {
                    onStoreSelected(store)
                }
            }

            // MARK: - 5. Rótulo Elegante e Discreto do Piso
            VStack {
                HStack {
                    Text(floor?.shortCode ?? "L1")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.5))
                        .clipShape(.capsule)
                    Spacer()
                }
                .padding(8)
                Spacer()
            }
            .frame(width: planWidth, height: planHeight)
        }
        .frame(width: planWidth, height: planHeight)
    }
}

// MARK: - Bloco de Loja 2D Proporcional

private struct Store2DBlockItemView: View {
    let store: Store
    let parentWidth: CGFloat
    let parentHeight: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    // Converte as coordenadas do modelo (0..1000, 0..700) para o tamanho do plano do mapa (340x110)
    private var normalizedX: CGFloat {
        let ratio = CGFloat(store.mapX) / 1000.0
        return (ratio * (parentWidth - 40)) + 20 - (parentWidth / 2.0)
    }

    private var normalizedY: CGFloat {
        let ratio = CGFloat(store.mapY) / 700.0
        return (ratio * (parentHeight - 30)) + 15 - (parentHeight / 2.0)
    }

    private var itemWidth: CGFloat {
        max(CGFloat(store.width) * (parentWidth / 1000.0), 30)
    }

    private var itemHeight: CGFloat {
        max(CGFloat(store.height) * (parentHeight / 700.0), 18)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(store.category.color.opacity(isSelected ? 0.65 : 0.35))

                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isSelected ? Color.white : store.category.color.opacity(0.8),
                        lineWidth: isSelected ? 2 : 1
                    )

                Text(store.name)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 2)
            }
            .frame(width: itemWidth, height: itemHeight)
            .shadow(color: isSelected ? .white.opacity(0.6) : .clear, radius: 4)
        }
        .buttonStyle(.plain)
        .offset(x: normalizedX, y: normalizedY)
    }
}

