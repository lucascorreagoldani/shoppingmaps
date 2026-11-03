import SwiftUI

// MARK: - Sheet de Preferências de Tema e Aparência

public struct ThemePreferencesSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var themeManager = ThemeManager.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AppThemeMode.allCases) { mode in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                themeManager.mode = mode
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(mode.accentColor.opacity(0.18))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: mode.iconName)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(mode.accentColor)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(mode.title)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)

                                    Text(mode.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if themeManager.mode == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Aparência do Aplicativo e Mapas")
                } footer: {
                    Text("No modo 'Automático pelo Horário', o ShoppingMaps se ajusta ao dia e à noite da sua cidade, mantendo o mapa claro durante o dia (06h às 18h) e escuro à noite.")
                }
            }
            .navigationTitle("Preferências de Tema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Concluir") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ThemePreferencesSheetView()
}

