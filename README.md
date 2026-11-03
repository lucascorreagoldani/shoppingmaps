# ShoppingMaps 🗺️🛍️

<p align="center">
  <strong>O Waze para Shoppings e Ambientes Fechados</strong><br>
  Navegação indoor inteligente, rápida e offline-first para nunca mais se perder em grandes centros comerciais.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.0" />
  <img src="https://img.shields.io/badge/iOS-17.0+-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 17+" />
  <img src="https://img.shields.io/badge/SwiftUI-Modern%20MV-blue?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/SwiftData-Offline--First-purple?style=for-the-badge&logo=apple&logoColor=white" alt="SwiftData" />
  <img src="https://img.shields.io/badge/Platform-100%25%20Native%20iOS-black?style=for-the-badge&logo=apple" alt="100% Native iOS" />
</p>

---

## 💡 Sobre o Projeto

Quem nunca perdeu minutos preciosos procurando onde ficava um banheiro, uma farmácia específica, o caixa eletrônico ou a loja em que precisava fazer uma troca em um shopping de 3 ou 4 andares?

O **ShoppingMaps** nasceu para resolver a desorientação em grandes ambientes fechados. Ele traz para o interior dos shoppings a mesma praticidade que o **Waze** trouxe para as ruas:
* **Visão em 2 Estágios (`MAP` e `MALL-{andar}`)**: Você visualiza o shopping destacado no mapa da cidade e, com um toque, o mapa da cidade dá lugar à planta arquitetural expandida do interior.
* **Câmera Móvel com Objetos Estáticos**: As paredes, corredores e lojas permanecem fixos no espaço enquanto você navega livremente com gestos naturais de arrasto (*pan*) e pinça (*pinch zoom*).
* **Navegação Multi-Pisos Instantânea**: Alterne entre pisos (Térreo, L1, L2, L3) sem telas de carregamento intermediárias.
* **100% Offline-First**: Shoppings têm barreiras físicas e subsolos com sinal 4G/Wi-Fi instável. O ShoppingMaps carrega localmente pelo **SwiftData** em 0ms, sincronizando novidades silenciosamente em segundo plano.
* **Como Chegar Integrado**: Calcula distância em tempo real e tempo estimado de deslocamento (ETA), abrindo sua rota favorita direto no **Apple Maps**, **Waze** ou **Google Maps**.
* **Tema Inteligente por Horário**: Adapta-se automaticamente à luz do dia (modo claro das 06h às 18h e modo escuro à noite).

---

## 🏛️ Shopping Piloto: Villa Romana Shopping (Florianópolis - SC)

O projeto piloto foi configurado e calibrado com base no **Villa Romana Shopping**:
* **Perímetro no Solo Real**: Contorno físico exato do edifício na Av. Madre Benvenuta via polígono geográfico (`MapPolygon`).
* **4 Andares Mapeados**: Piso G (Garagem & Hipermercado), Piso L1 (Grandes Marcas), Piso L2 (Moda & Café) e Piso L3 (Praça de Alimentação, Restaurantes & Cinemas).
* **~24 Lojas e Serviços**: Cadastrados com coordenadas relativas de arquitetura, horários, categorias e ícones dedicados.

---

## 📐 Arquitetura do Software (Clean Architecture & SOLID)

O código segue estritamente as diretrizes modernas do ecossistema Apple com **Swift 6 Strict Concurrency**:

```text
ios/ShoppingMapsApp/
├── App/                  # Ciclo de vida (@main), inicialização resiliente e Splash Screen
├── Domain/               # Regras de Negócio e Casos de Uso (Puros e Desacoplados)
│   ├── Entities/         # StoreCategory (16 categorias com cores/ícones), MapStage
│   └── UseCases/         # SyncMallUseCase, LoadMallConfigUseCase
├── Data/                 # Persistência e Fontes de Dados
│   ├── SwiftData/        # @Model (ShoppingMall, FloorLevel, Store, NavigationNode)
│   ├── Repositories/     # SwiftDataMallRepository (protocol-oriented com @MainActor)
│   ├── Network/          # URLSessionMallNetworkService (fallback local automático)
│   └── DTOs/             # Schemas Decodable & Sendable para REST API
├── Presentation/         # Camada de Interface 100% Declarativa (SwiftUI)
│   ├── Home/             # ContentView (seleção de shoppings e resumo de andares)
│   ├── Map/              # IndoorMapView, MallInteriorView, FloorPickerView
│   ├── Navigation/       # ExternalNavigationSheetView (Apple Maps, Waze, Google Maps)
│   ├── Settings/         # ThemePreferencesSheetView (Preferências de Aparência)
│   └── Splash/           # SplashLoadingView (Radar pulsante de inicialização)
├── Core/                 # Serviços Utilitários Globais
│   ├── Location/         # UserLocationService (CoreLocation + cálculo de ETA via MKDirections)
│   ├── Navigation/       # ExternalNavigationService (URL Schemes para Waze e Google Maps)
│   └── Theme/            # ThemeManager (Padrão do Sistema, Automático por Horário, Claro, Escuro)
└── Resources/
    └── Configs/          # Arquivos de shopping desacoplados {country}-{state}-{city}-{name}.json
```

---

## 🔌 Zero Hardcode: Como Adicionar Novos Shoppings

Qualquer shopping pode ser incluído no aplicativo sem alterar uma única linha de código Swift, apenas adicionando um arquivo JSON no padrão:

```text
{country}-{state}-{city}-{name}.json
```

Exemplo: [`brazil-santacatarina-florianopolis-villaromanashopping.json`](ios/ShoppingMapsApp/Resources/Configs/brazil-santacatarina-florianopolis-villaromanashopping.json)

```json
{
  "id": 1,
  "slug": "villa-romana-florianopolis",
  "displayName": "Villa Romana Shopping",
  "city": "Florianópolis",
  "stateCode": "SC",
  "coordinates": {
    "latitude": -27.589825,
    "longitude": -48.515096
  },
  "floors": [
    {
      "shortCode": "L1",
      "displayName": "Piso L1",
      "stores": [
        {
          "displayName": "Zara",
          "category": "fashion",
          "mapX": 250.0,
          "mapY": 350.0,
          "width": 120.0,
          "height": 70.0
        }
      ]
    }
  ]
}
```

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
* macOS com **Xcode 16.0+** instalado (suporte a iOS 17+ e Swift 6).
* [XcodeGen](https://github.com/yonaskolb/XcodeGen) instalado via Homebrew:
  ```bash
  brew install xcodegen
  ```

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/SEU_USUARIO/shoppingmaps.git
   cd shoppingmaps
   ```

2. **Gere o projeto Xcode:**
   O projeto utiliza XcodeGen para manter o controle de versão 100% limpo, sem conflitos em arquivos `.pbxproj`:
   ```bash
   cd ios
   xcodegen generate
   ```

3. **Abra e execute:**
   ```bash
   open ShoppingMaps.xcodeproj
   ```
   * Selecione qualquer simulador com **iOS 17.0+** (ex: *iPhone 16 Pro*).
   * Pressione `Cmd + R` para compilar e rodar.

---

## 🗺️ Roadmap de Desenvolvimento

- [x] **Etapa 0: Limpeza & Setup Inicial** (XcodeGen, Swift 6 e regras estritas de concorrência)
- [x] **Etapa 1: Arquitetura Limpa & SwiftData** (Repositórios desacoplados, DTOs e JSON externo)
- [x] **Etapa 2: Motor de Mapa em 2 Estágios**
  - [x] Estágio 1 (`MAP`): Apple Maps com perímetro real no solo (`MapPolygon`)
  - [x] Estágio 2 (`MALL-{andar}`): Interior 2D com deep zoom e câmera virtual móvel
  - [x] Seletor de andares vertical (`FloorPickerView`)
  - [x] Sincronização remota Offline-First com `URLSession` e cache silencioso
  - [x] Tema dinâmico (Automático pelo Horário do dia) e Splash Screen fluida
  - [x] Integração para abrir rotas externas no Apple Maps, Waze e Google Maps
- [ ] **Etapa 3: Busca & Descoberta Rápida**
  - [ ] Barra de busca com autocomplete no topo (`MallSearchBarView`)
  - [ ] Filtros rápidos por chips: 🍔 Alimentação, 🚻 Banheiros, ☕ Cafés, 🅿️ Estacionamento
  - [ ] Bottom Sheet expansível com horários e telefone da loja
- [ ] **Etapa 4: Motor de Roteamento Indoor Turn-by-Turn (Estilo Waze)**
  - [ ] Grafo de corredores com algoritmo de menor caminho A* (`IndoorRouteCalculator`)
  - [ ] Traçado de linha animada no piso com conexões de escada rolante e elevador
  - [ ] Instruções passo a passo na parte superior da tela

---

## 🤝 Como Contribuir

Contribuições são muito bem-vindas! Se você deseja mapear um shopping da sua cidade ou aprimorar o código:
1. Faça um Fork do projeto.
2. Crie uma branch para sua funcionalidade: `git checkout -b feature/novo-shopping`.
3. Adicione o arquivo de configuração `.json` do shopping ou suas melhorias de código.
4. Envie suas alterações: `git commit -m 'feat: adiciona shopping XPTO'`.
5. Abra um **Pull Request**.

---

## 📄 Licença

Distribuído sob a licença **MIT**. Consulte `LICENSE` para mais informações.
