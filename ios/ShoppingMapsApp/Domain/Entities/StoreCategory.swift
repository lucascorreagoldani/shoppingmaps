import SwiftUI

// MARK: - Entidade de Domínio: Categorias de Lojas e Serviços (SOLID - Domain Entity)

public enum StoreCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case dining
    case apparel
    case footwear
    case beauty
    case jewelry
    case electronics
    case books
    case home
    case toys
    case cinema
    case fitness
    case grocery
    case services
    case restroom
    case financial
    case parking

    public var id: String { rawValue }

    // MARK: - Nome de Exibição Formatado
    public var displayName: String {
        switch self {
        case .dining:
            return "Alimentação & Restaurantes"
        case .apparel:
            return "Moda & Vestuário"
        case .footwear:
            return "Calçados & Bolsas"
        case .beauty:
            return "Beleza & Perfumaria"
        case .jewelry:
            return "Joias, Óticas & Relógios"
        case .electronics:
            return "Tecnologia & Celulares"
        case .books:
            return "Livros & Papelaria"
        case .home:
            return "Casa & Decoração"
        case .toys:
            return "Brinquedos & Games"
        case .cinema:
            return "Cinema & Lazer"
        case .fitness:
            return "Academia & Bem-Estar"
        case .grocery:
            return "Supermercado & Empório"
        case .services:
            return "Serviços & Informações"
        case .restroom:
            return "Sanitários & Fraldário"
        case .financial:
            return "Bancos & Caixas 24h"
        case .parking:
            return "Estacionamento & Valet"
        }
    }

    // MARK: - Ícone SF Symbol Oficial
    public var iconName: String {
        switch self {
        case .dining:
            return "fork.knife"
        case .apparel:
            return "tshirt.fill"
        case .footwear:
            return "shoe.fill"
        case .beauty:
            return "sparkles"
        case .jewelry:
            return "sparkle"
        case .electronics:
            return "laptopcomputer"
        case .books:
            return "book.fill"
        case .home:
            return "house.fill"
        case .toys:
            return "gamecontroller.fill"
        case .cinema:
            return "film.fill"
        case .fitness:
            return "figure.run"
        case .grocery:
            return "cart.fill"
        case .services:
            return "info.circle.fill"
        case .restroom:
            return "figure.dress.line.vertical.figure"
        case .financial:
            return "banknote.fill"
        case .parking:
            return "parkingsign.circle.fill"
        }
    }

    // MARK: - Cor Primária da Categoria (Design System Waze)
    public var color: Color {
        switch self {
        case .dining:
            return Color(red: 1.00, green: 0.50, blue: 0.15) // Laranja Vibrante
        case .apparel:
            return Color(red: 0.65, green: 0.35, blue: 0.85) // Roxo / Violeta
        case .footwear:
            return Color(red: 0.35, green: 0.40, blue: 0.88) // Índigo
        case .beauty:
            return Color(red: 0.95, green: 0.35, blue: 0.65) // Rosa / Pink
        case .jewelry:
            return Color(red: 0.85, green: 0.65, blue: 0.20) // Dourado / Ouro
        case .electronics:
            return Color(red: 0.10, green: 0.70, blue: 0.95) // Azul Ciano
        case .books:
            return Color(red: 0.65, green: 0.45, blue: 0.32) // Café / Marrom
        case .home:
            return Color(red: 0.92, green: 0.75, blue: 0.25) // Amarelo Dourado
        case .toys:
            return Color(red: 0.20, green: 0.80, blue: 0.55) // Verde Menta
        case .cinema:
            return Color(red: 0.92, green: 0.22, blue: 0.25) // Vermelho Carmim
        case .fitness:
            return Color(red: 0.25, green: 0.78, blue: 0.42) // Verde Esmeralda
        case .grocery:
            return Color(red: 0.15, green: 0.50, blue: 0.95) // Azul Royal
        case .services:
            return Color(red: 0.55, green: 0.60, blue: 0.68) // Cinza Metálico
        case .restroom:
            return Color(red: 0.12, green: 0.75, blue: 0.75) // Teal / Verde Água
        case .financial:
            return Color(red: 0.18, green: 0.65, blue: 0.38) // Verde Banco
        case .parking:
            return Color(red: 0.22, green: 0.45, blue: 0.75) // Azul Petróleo
        }
    }

    // MARK: - Código Hexadecimal (para persistência e APIs externas)
    public var hexColor: String {
        switch self {
        case .dining:
            return "#FF8026"
        case .apparel:
            return "#A659D9"
        case .footwear:
            return "#5966E0"
        case .beauty:
            return "#F259A6"
        case .jewelry:
            return "#D9A633"
        case .electronics:
            return "#1AB2F2"
        case .books:
            return "#A67352"
        case .home:
            return "#EBBF40"
        case .toys:
            return "#33CC8C"
        case .cinema:
            return "#EB3840"
        case .fitness:
            return "#40C76B"
        case .grocery:
            return "#2680F2"
        case .services:
            return "#8C99AD"
        case .restroom:
            return "#1EBFC0"
        case .financial:
            return "#2EA661"
        case .parking:
            return "#3873BF"
        }
    }

    // MARK: - Cor Suave para Preenchimento no Mapa (Background Fill)
    public var bgFillColor: Color {
        color.opacity(0.18)
    }

    // MARK: - Cor de Destaque / Borda
    public var borderColor: Color {
        color.opacity(0.85)
    }

    // MARK: - Inicializador Seguro com Fallback
    public static func from(raw: String) -> StoreCategory {
        let clean = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return StoreCategory(rawValue: clean) ?? .services
    }
}

