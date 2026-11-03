# ShoppingMaps Project - Agent Guidelines & Context

This repository contains the `ShoppingMaps` project ("O Waze para Shoppings e Ambientes Fechados"). Development priority is **100% Native iOS First** (Swift & SwiftUI), followed by 100% Native Android (Kotlin & Jetpack Compose), and a unified shared backend/data layer (PostgreSQL via Neon, Redis for live caching).

## Guidelines & Rules

All code and design contributions must follow:
1. [Swift Guidelines](file:///Users/lucas/Documents/Develop/shoppingmaps/.agents/rules/swift-guidelines.md)
2. [iOS ShoppingMaps Standards](file:///Users/lucas/Documents/Develop/shoppingmaps/.agents/rules/ios-shoppingmaps-standards.md)
3. Available Skills in `.agents/skills/`:
   - iOS: `swiftui-patterns`, `swiftui-layout-components`, `swiftui-gestures`, `swiftui-animation`, `mapkit`, `swiftdata`, `swift-architecture`, `swift-concurrency`, `swift-charts`, `ios-localization`, `widgetkit`.

## Xcode MCP Integration
The project uses Apple's official `xcrun mcpbridge`:
- `DocumentationSearch`: Consultar documentação oficial de APIs Apple antes de codificar.
- `BuildProject`: Validar compilação do projeto no Xcode.
- `GetBuildLog`: Obter diagnósticos estruturados de erros.
- `RenderPreview`: Renderizar e inspecionar previews SwiftUI.

## Key Commands & Workflow
- **Current Target**: Native iOS inside `ios/ShoppingMaps.xcodeproj` (source in `ios/ShoppingMapsApp/`).
- **UI Framework**: SwiftUI targeting iOS 17+ with Swift 6 strict concurrency.
- **State Management**: `@Observable` classes marked `@MainActor`, injected with `@State`, `@Bindable`, or `@Environment`.
- **Formatting**: Always modern `FormatStyle` (e.g. `formatted(.number)`, `formatted(date:time:)`).
- **Persistence**: SwiftData offline-first for shopping mall layouts, stores, and indoor routing graphs.
