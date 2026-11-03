# ShoppingMaps 🗺️🛍️

**O Waze para Shoppings e Ambientes Fechados**

O **ShoppingMaps** é uma aplicação focada em revolucionar a experiência de navegação indoor dentro de centros comerciais, shoppings e complexos multifuncionais. Com uma interface de mapa ultra fluida, com deep zoom e perspectiva dinâmica (estilo Waze), o app permite que o usuário encontre rapidamente qualquer loja, restaurante, serviço ou comodidade (banheiros, elevadores, caixas eletrônicos, fraldários) e trace rotas inteligentes com instruções passo a passo através de múltiplos andares.

## Estrutura do Repositório

```text
shoppingmaps/
├── ios/          # Projeto nativo iOS (Swift 6, SwiftUI, SwiftData, MapKit/Indoor Canvas)
├── android/      # Projeto nativo Android (Kotlin, Jetpack Compose) [Futuro]
├── shared/       # Contratos de API, schemas de dados dos shoppings e grafos de navegação
└── docs/         # Especificações de arquitetura, plantas baixas e rotas indoor
```

## Arquitetura & Diretrizes

1. **iOS (Nativo - Prioridade 1)**:
   - **Linguagem**: Swift 6.0+ com Strict Concurrency
   - **UI**: SwiftUI targeting iOS 17+
   - **Arquitetura**: MV com Observation (`@Observable` + `@MainActor`)
   - **Persistência**: SwiftData offline-first
   - **Renderização Indoor**: Canvas vetorial interativo / MapKit com suporte a Deep Zoom, pan e rotação
   - **Roteamento Indoor**: Grafo de nós com algoritmo de menor caminho (A* / Dijkstra) com suporte a multi-andares

2. **Android (Nativo - Prioridade 2)**:
   - **Linguagem**: Kotlin
   - **UI**: Jetpack Compose
   - **Arquitetura**: MVVM com StateFlow / Coroutines

3. **Backend & Sincronização**:
   - PostgreSQL (Neon) para persistência de shoppings, lojas e grafos de corredores
   - Redis para caching e sessões rápidas
