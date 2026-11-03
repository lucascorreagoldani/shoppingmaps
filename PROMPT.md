# Modelo de Prompt para Desenvolvimento iOS (ShoppingMaps)

Use este modelo de prompt sempre que for solicitar a criação, refatoração ou expansão de uma funcionalidade no projeto **ShoppingMaps**. Ele foi calibrado para ativar automaticamente as **Skills**, **Rules** e padrões de engenharia sênior configurados no repositório.

---

```markdown
## Contexto do Projeto
Você está atuando como Engenheiro iOS Sênior no projeto **ShoppingMaps** (`ios/ShoppingMaps.xcodeproj`), desenvolvendo uma aplicação nativa "estilo Waze para shoppings e ambientes fechados" em Swift e SwiftUI para iOS 17+.

## Regras e Skills Obrigatórias
Antes de gerar o código, consulte e siga estritamente:
1. `AGENTS.md` e `.agents/rules/swift-guidelines.md` (Swift 6 Concurrency, `@Observable` + `@MainActor`, `FormatStyle`, `navigationDestination`, etc.).
2. `.agents/rules/ios-shoppingmaps-standards.md` (Renderização de mapas indoor, deep zoom fluido, multi-andares, nós de navegação e grafo para A*).
3. As skills em `.agents/skills/` relevantes para esta tarefa:
   - [ ] `swiftui-patterns` / `swiftui-gestures` / `swiftui-animation`
   - [ ] `mapkit` / `swiftdata` / `swift-architecture`
   - [ ] `swift-concurrency` / `ios-localization` / `swift-codable`

## Objetivo da Tarefa
[Descreva aqui o que precisa ser feito. Exemplo: "Implementar o componente de mapa indoor com deep zoom, pan, suporte a múltiplos andares e renderização das lojas com toque interativo"]

## Requisitos Específicos
- **Entradas**: [Ex: Lista de lojas do piso atual, coordenadas normalizadas de cada loja, posição atual do usuário]
- **Saídas/Estado**: [Ex: Loja selecionada, nível de zoom atual, piso ativo (Térreo, 1º Piso), rota traçada com polyline]
- **Tratamento de Exceções**: [Ex: Loja sem coordenadas cadastradas, destino em andar diferente sem rota acessível por elevador]
- **Design/UI** (se aplicável): [Ex: Interface moderna estilo Waze com cards flutuantes, cores por categoria de loja, seletor vertical de andares e feedback háptico ao tocar]

## Restrições Técnicas
- Não use Grand Central Dispatch (`DispatchQueue`). Use Swift Concurrency (`async/await`, `Task`, `actors`).
- Não use `ObservableObject` ou `@Published`. Use `@Observable` com `@MainActor`.
- Não use formatação de strings em C (`String(format:)`). Use `FormatStyle`.
- Não use `.cornerRadius()`, use `.clipShape(.rect(cornerRadius:))`.
- Não use `.foregroundColor()`, use `.foregroundStyle()`.
- Garanta que operações pesadas (ex: cálculo de rota A*) rodem em um `actor` em background, sem travar a Main Thread e a taxa de 60/120fps de renderização do mapa.

## Critérios de Aceite (Definition of Done)
1. Código 100% compilável, modular e estritamente seguro contra data-races (Swift 6).
2. Views decompostas em sub-componentes reutilizáveis e focados.
3. Testes unitários com o framework moderno **Swift Testing** (`import Testing`, `@Test`, `#expect`).
```

---

## Exemplos Prontos de Uso:

### Exemplo 1: Criando os Modelos SwiftData de Shoppings e Lojas
> *"Atuando como Engenheiro iOS Sênior sob as regras do `AGENTS.md` e `.agents/rules/ios-shoppingmaps-standards.md`, implemente os modelos SwiftData `ShoppingMall.swift`, `FloorLevel.swift`, `Store.swift` e `StoreCategory.swift` em `ios/ShoppingMapsApp/Models/`. Eles devem suportar múltiplos andares, categorização de lojas com cores e ícones SF Symbols, horários de funcionamento e dados espaciais vetoriais para renderização no mapa."*

### Exemplo 2: Criando o Visualizador de Mapa Indoor com Deep Zoom
> *"Crie o componente de visualização de mapa `IndoorMapView.swift` e seu `MallMapViewModel.swift` usando SwiftUI e `@Observable`. O mapa deve suportar deep zoom contínuo (`MagnifyGesture`), pan (`DragGesture`), seletor vertical flutuante de andares (Térreo, 1º Piso, etc.) e renderização das lojas com detecção de toque para seleção."*

### Exemplo 3: Criando o Motor de Roteamento Indoor (A* Algorithm)
> *"Implemente o ator `IndoorRouteCalculator.swift` em `ios/ShoppingMapsApp/Services/`. Ele deve receber um grafo de corredores (`NavigationGraph`), o ponto de partida do usuário e o destino (loja ou POI), calculando a rota de menor distância usando o algoritmo A*. Se o destino estiver em outro piso, deve rotear até a escada rolante ou elevador mais próximo e continuar a rota no piso de destino, gerando instruções passo a passo (turn-by-turn)."*

### Exemplo 4: Criando a Bottom Sheet de Detalhes da Loja e Busca Rápida
> *"Implemente a view `StoreDetailSheetView.swift` e a barra de busca `MallSearchBarView.swift`. Ao clicar em uma loja no mapa ou buscá-la por nome/categoria (ex: 'Praça de Alimentação' ou 'Banheiro'), o sheet deve surgir com animação suave, exibindo foto, horário de funcionamento, piso e o botão em destaque 'Ir até a Loja', que ativa a rota no mapa."*
