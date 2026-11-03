# Roadmap de Implementação do ShoppingMaps

Este roadmap detalha as etapas práticas para transformar o MVP do **ShoppingMaps** em realidade utilizando o modelo de prompts em `PROMPT.md`.

---

- [x] **Etapa 0: Limpeza & Inicialização do Projeto**
  - [x] Remoção completa do código legado de corrida (`RunningApp`).
  - [x] Configuração do novo projeto Xcode `ShoppingMaps.xcodeproj` com XcodeGen.
  - [x] Criação do Hello World funcional no `ContentView.swift`.
  - [x] Criação e calibração das regras `.agents/rules/ios-shoppingmaps-standards.md`.
  - [x] Atualização de `AGENTS.md`, `README.md`, `context/ios-architecture.md` e `PROMPT.md`.

- [x] **Etapa 1: Arquitetura Limpa, SOLID & Configuração via JSON**
  - [x] Reorganização do projeto em camadas: `App`, `Data`, `Domain`, `Presentation`, `Resources`.
  - [x] Criação do arquivo de configuração padronizado: `brazil-santacatarina-florianopolis-villaromanashopping.json`.
  - [x] Schemas `MallConfigDTO` (Codable, Sendable) preparados para API REST e arquivos locais.
  - [x] Interface `MallRepositoryProtocol` (DIP do SOLID) e implementação `SwiftDataMallRepository` com operações de CRUD e busca.
  - [x] Caso de Uso `LoadMallConfigUseCase` para carregar e sincronizar arquivos de shopping sem hardcode.

- [x] **Etapa 2: Motor de Mapa Indoor com Deep Zoom (SwiftUI Canvas)**
  - [x] `MallMapViewModel` (@Observable @MainActor) para controle de zoom, pan, andar ativo e foco de lojas.
  - [x] `IndoorMapView` com suporte a `MagnifyGesture` (zoom de 0.6x a 4.5x) e `DragGesture` (pan contínuo).
  - [x] Seletor vertical flutuante de andares (`FloorPickerView`).
  - [x] Renderização de corredores (Boulevard) e lojas com cores temáticas por categoria.
  - [x] Marcador da posição do usuário estilo Waze (ponto azul pulsante).
  - [x] Card flutuante de detalhes da loja (`StoreQuickPreviewCardView`) com botão de rota.

- [ ] **Etapa 3: Busca Instantânea, Autocomplete & Filtros por Categoria**
  - [ ] Barra de busca com autocomplete no topo (`MallSearchBarView`).
  - [ ] Filtros rápidos (Chips: Banheiros, Alimentação, Cafés, Farmácia, Estacionamento).
  - [ ] Bottom Sheet expansível com detalhes da loja, horários e botão de ação ("Como Chegar").

- [ ] **Etapa 4: Motor de Roteamento Indoor Turn-by-Turn (Estilo Waze)**
  - [ ] Algoritmo A* implementado em um `actor` concorrente (`IndoorRouteCalculator`).
  - [ ] Traçado de polyline animada nos corredores ligando a origem até a loja de destino.
  - [ ] Suporte a transição de piso via escada rolante ou elevador.
  - [ ] Card superior flutuante com instruções passo a passo (turn-by-turn).

- [ ] **Etapa 5: Testes & Refinamento**
  - [ ] Testes unitários com o framework Swift Testing para o repositório, use cases e cálculo de rotas.
  - [ ] Validação de fluidez a 60/120fps no simulador e dispositivos.
