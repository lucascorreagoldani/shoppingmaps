import SwiftUI

public struct StoreQuickPreviewCardView: View {
    let store: Store
    let onDismiss: () -> Void
    let onRouteRequested: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                // Ícone temático da categoria
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(store.category.color.opacity(0.18))
                        .frame(width: 48, height: 48)

                    Image(systemName: store.category.iconName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(store.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(store.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)

                        if store.isAnchor {
                            Text("Âncora")
                                .font(.caption2.weight(.black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(store.category.color.opacity(0.15))
                                .clipShape(.capsule)
                                .foregroundStyle(store.category.color)
                        }
                    }

                    Text("\(store.category.displayName) • Loja \(store.storeNumber)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(store.openingHours)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                if let floor = store.floor {
                    HStack(spacing: 6) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(floor.name)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Botão de ação primária estilo Waze
            Button(action: onRouteRequested) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.headline)
                    Text("Traçar Rota até a Loja")
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color(uiColor: .systemBackground))
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }
}

