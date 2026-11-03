# Arquitetura e Contexto do App iOS (ShoppingMaps)

## 1. Visão Geral
O aplicativo **ShoppingMaps** é uma solução de navegação indoor nativa em Swift 6 e SwiftUI para iOS 17+, desenhada para oferecer uma experiência "estilo Waze" dentro de shopping centers com arquitetura modular, **Clean Architecture** e princípios **SOLID**.

---

## 2. Estrutura Modular de Camadas (`ios/ShoppingMapsApp/`)

```text
ios/ShoppingMapsApp/
├── App/
│   └── ShoppingMapsApp.swift          # Entrypoint (@main), injeção de dependências e bootstrap
├── Data/                              # Camada de Dados & Persistência (Repository Pattern)
│   ├── DTOs/
│   │   └── MallConfigDTO.swift        # Schemas Codable para parsing de JSON / API REST
│   ├── Repositories/
│   │   ├── MallRepositoryProtocol.swift # Interface abstrata (DIP do SOLID)
│   │   └── SwiftDataMallRepository.swift# Implementação de CRUD com SwiftData
│   └── SwiftData/
│       └── MallModels.swift           # Modelos persistentes (@Model)
├── Domain/                            # Regras de Negócio Puras (Use Cases)
│   └── UseCases/
│       ├── LoadMallConfigUseCase.swift# Carregamento e sincronização de JSONs de shoppings
│       └── SearchStoresUseCase.swift  # Motor de busca e filtros de lojas/serviços
├── Presentation/                      # Camada Visual (SwiftUI + @Observable)
│   ├── Home/
│   │   └── ContentView.swift          # Seleção e visão geral do shopping
│   └── Map/
│       ├── IndoorMapView.swift        # Tela principal com gestos combinados (deep zoom + pan)
│       ├── IndoorCanvasView.swift     # Renderização vetorial dos corredores e lojas
│       ├── FloorPickerView.swift      # Seletor vertical flutuante de andares
│       ├── StoreQuickPreviewCardView.swift # Card flutuante de detalhes rápidos
│       └── MallMapViewModel.swift     # Gerenciamento de estado reativo da câmera e seleção
└── Resources/                         # Recursos estáticos e arquivos de configuração
    └── Configs/
        └── brazil-santacatarina-florianopolis-villaromanashopping.json
```

---

## 3. Padrão Global de Configuração de Shoppings
Cada shopping center é definido por um arquivo JSON no padrão de nomenclatura:
`{country}-{state}-{city}-{name}.json`

### Exemplo de Metadados:
- **Slug**: `brazil-santacatarina-florianopolis-villaromanashopping`
- **UUIDs Imutáveis**: ID fixo do shopping, de cada piso e de cada loja.
- **Sincronização Periódica**: Campo `lastUpdated` (ISO 8601) e `schemaVersion` para consulta inteligente em API REST sem download redundante.
- **Geolocalização & Limites**: Latitude, longitude, endereço completo e dimensões cartesianas do Canvas.
- **Catálogo & POIs**: Coordenadas `(mapX, mapY, width, height)`, horários, telefones, tags de busca e indicador de loja âncora.
