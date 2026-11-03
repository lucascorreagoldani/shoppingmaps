import SwiftUI

// MARK: - Tela de Abertura e Carregamento Fluida (Splash Screen)
// Inspirada na identidade visual moderna do ShoppingMaps ("Waze para Ambientes Fechados")

public struct SplashLoadingView: View {
    let statusMessage: String
    @State private var isPulsing: Bool = false

    public init(statusMessage: String = "Preparando mapas indoor...") {
        self.statusMessage = statusMessage
    }

    public var body: some View {
        ZStack {
            // Fundo escuro imersivo com gradiente sutil
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.08, blue: 0.13),
                    Color(red: 0.02, green: 0.03, blue: 0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                // MARK: - Ícone Central com Radar de Pulso Estilo Waze
                ZStack {
                    // Ondas de pulso concêntricas do radar
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.blue.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 100, height: 100)
                            .scaleEffect(isPulsing ? 2.4 : 0.8)
                            .opacity(isPulsing ? 0.0 : 0.7)
                            .animation(
                                .easeOut(duration: 2.2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.55),
                                value: isPulsing
                            )
                    }

                    // Glow de fundo
                    Circle()
                        .fill(Color.blue.opacity(0.25))
                        .frame(width: 110, height: 110)
                        .blur(radius: 20)

                    // Emblema Central
                    ZStack {
                        RoundedRectangle(cornerRadius: 26)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: .blue.opacity(0.55), radius: 18, y: 8)

                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 180)

                // MARK: - Identidade e Tipografia
                VStack(spacing: 8) {
                    Text("ShoppingMaps")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(0.5)

                    Text("O Waze para Ambientes Fechados")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.70))
                }

                Spacer()

                // MARK: - Status de Carregamento e Sincronização
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white.opacity(0.9))
                        .controlSize(.regular)

                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.25), value: statusMessage)
                }
                .padding(.bottom, 48)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    SplashLoadingView(statusMessage: "Sincronizando lojas do Villa Romana...")
}

