import SwiftUI
import CoreLocation

// MARK: - Sheet de Seleção de App de Navegação (Apple Maps, Waze, Google Maps)

public struct ExternalNavigationSheetView: View {
    let destination: CLLocationCoordinate2D
    let destinationName: String
    let address: String
    let etaInfo: (distance: CLLocationDistance, travelTime: TimeInterval)?

    @Environment(\.dismiss) private var dismiss

    public init(
        destination: CLLocationCoordinate2D,
        destinationName: String,
        address: String,
        etaInfo: (distance: CLLocationDistance, travelTime: TimeInterval)? = nil
    ) {
        self.destination = destination
        self.destinationName = destinationName
        self.address = address
        self.etaInfo = etaInfo
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header com Informações de Destino e Trânsito
                VStack(spacing: 8) {
                    Text(address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if let eta = etaInfo {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "car.fill")
                                    .foregroundStyle(.blue)
                                Text(UserLocationService.shared.formatTravelTime(eta.travelTime))
                                    .fontWeight(.bold)
                            }

                            Text("•")
                                .foregroundStyle(.secondary)

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.secondary)
                                Text(UserLocationService.shared.formatDistance(eta.distance))
                            }
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(.capsule)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)

                // Opções Diretas de Navegação (Apple Maps, Waze, Google Maps)
                VStack(spacing: 12) {
                    ForEach(ExternalNavigationApp.allCases) { app in
                        Button {
                            ExternalNavigationService.shared.open(
                                app: app,
                                destination: destination,
                                destinationName: destinationName
                            )
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(app.iconColor.opacity(0.15))
                                        .frame(width: 46, height: 46)

                                    Image(systemName: app.iconName)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(app.iconColor)
                                }

                                Text(app.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle(destinationName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
        .presentationDetents([.fraction(0.48), .medium])
        .presentationDragIndicator(.visible)
    }
}
