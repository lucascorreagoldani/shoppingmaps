import SwiftUI

// MARK: - Modo de Tema e Aparência do ShoppingMaps (Preferences)

public enum AppThemeMode: String, CaseIterable, Identifiable, Sendable {
    case autoTime = "auto_time"
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .autoTime:
            return "Automático pelo Horário"
        case .system:
            return "Padrão do Sistema (iOS)"
        case .light:
            return "Modo Claro"
        case .dark:
            return "Modo Escuro"
        }
    }

    public var subtitle: String {
        switch self {
        case .autoTime:
            return "Claro das 06:00 às 18:00, Escuro à noite"
        case .system:
            return "Acompanha o tema configurado no iPhone"
        case .light:
            return "Fixar sempre em tema claro"
        case .dark:
            return "Fixar sempre em tema escuro"
        }
    }

    public var iconName: String {
        switch self {
        case .autoTime:
            return "clock.badge.checkmark.fill"
        case .system:
            return "circle.righthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.stars.fill"
        }
    }

    public var accentColor: Color {
        switch self {
        case .autoTime:
            return .orange
        case .system:
            return .blue
        case .light:
            return .yellow
        case .dark:
            return .indigo
        }
    }
}

// MARK: - Gerenciador Reativo de Tema

@Observable
@MainActor
public final class ThemeManager {
    public static let shared = ThemeManager()

    public var mode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: "app_theme_mode")
            updateResolvedScheme()
        }
    }

    /// ColorScheme efetivo a ser aplicado no SwiftUI (nil significa seguir o sistema)
    public private(set) var resolvedScheme: ColorScheme?

    /// Indica se o tema ativo no momento é escuro
    public var isCurrentlyDark: Bool {
        if let resolvedScheme {
            return resolvedScheme == .dark
        }
        // Se nil (sistema), assume o padrão ou horário
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 6 || hour >= 18
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_theme_mode") ?? AppThemeMode.autoTime.rawValue
        self.mode = AppThemeMode(rawValue: saved) ?? .autoTime
        updateResolvedScheme()
    }

    public func updateResolvedScheme() {
        switch mode {
        case .system:
            resolvedScheme = nil
        case .light:
            resolvedScheme = .light
        case .dark:
            resolvedScheme = .dark
        case .autoTime:
            let hour = Calendar.current.component(.hour, from: Date())
            // 06:00 às 17:59 -> Claro; 18:00 às 05:59 -> Escuro
            let isDaytime = (hour >= 6 && hour < 18)
            resolvedScheme = isDaytime ? .light : .dark
        }
    }
}

