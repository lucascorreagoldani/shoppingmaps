# iOS ShoppingMaps Standards & Indoor Navigation Guidelines

Requisitos de engenharia e padrões arquiteturais específicos para o projeto **ShoppingMaps** no iOS:

## 1. Visão Geral & Filosofia de Produto
O ShoppingMaps atua como o "Waze para Shoppings e Ambientes Fechados". A experiência deve ser:
- **Instantânea e Fluida**: O mapa deve responder a zoom extremo (deep zoom), pan e rotações com taxa constante de 60/120fps.
- **Consciência de Piso (Multi-Floor Awareness)**: Transição natural entre pisos/andares (Térreo, 1º Piso, Subsolo, etc.) sem perda do contexto de navegação.
- **Roteamento Indoor Inteligente**: Cálculo do caminho mais curto entre a posição atual do usuário (ou ponto de partida selecionado) e qualquer loja ou ponto de interesse (POI), com suporte a conectores verticais (escadas rolantes, elevadores) e rotas acessíveis.
- **Busca Rápida & Descoberta**: Localização ágil por nome da loja, categorias (ex: Fast Food, Vestuário, Farmácia) ou comodidades essenciais (Banheiro, Fraldário, Caixa Eletrônico, Estacionamento).

## 2. Sistema de Coordenadas & Renderização Indoor
- **Espaço de Coordenadas Indoor**:
  - Utilizar sistema de coordenadas normalizado (0.0 a 1.0) ou vetorial local por piso para desacoplar a geometria da planta de variações de GPS externo (frequentemente instável sob coberturas de concreto).
  - Em integrações com `MapKit`, projetar coordenadas sobre polígonos de sobreposição (`MKOverlay`) ou usar renderização nativa baseada em `SwiftUI.Canvas` / vetores (`Path`) para garantir controle total sobre estilização, cores de lojas e zoom ultra aproximado.
- **Deep Zoom & Desempenho Gráfico**:
  - Implementar zoom suave e contínuo com gestos combinados (`MagnifyGesture`, `DragGesture`).
  - Níveis de detalhe dinâmicos (LOD - Level of Detail): em zoom aberto, mostrar apenas corredores principais e âncoras; em zoom aproximado, revelar nomes de lojas, números e ícones de serviços.
  - Usar renderização acelerada por GPU (`.drawingGroup()` quando aplicável em Canvas complexos).

## 3. Estrutura de Dados & Grafo de Navegação (Indoor Graph)
- **Modelos Principais**:
  - `ShoppingMall`: Entidade raiz com metadados do shopping, lista de pisos e limites espaciais.
  - `FloorLevel`: Representa um piso/andar (ex: ordinal -1 para subsolo, 0 para térreo, 1 para 1º piso), contendo polígonos de corredores, lojas e pontos de conexão.
  - `Store` / `POI`: Representa lojas, quiosques e serviços. Possui nome, categoria, piso, posição no mapa, horários e tags de busca.
  - `NavigationNode` & `NavigationEdge`: Grafo de nós que mapeia os corredores caminháveis do shopping para algoritmos de busca de caminho.
  - `VerticalConnector`: Conecta dois nós em andares distintos (tipo: `elevator`, `escalator`, `stairs`).
- **Algoritmo de Roteamento**:
  - Algoritmo A* (A-Star) ou Dijkstra para calcular o caminho de menor custo em nós do grafo.
  - O cálculo deve ser executado fora da MainActor (`actor IndoorRouteCalculator`), retornando a rota completa subdividida por piso e com instruções passo a passo (ex: "Siga 30m em frente e pegue a escada rolante para o 1º Piso").

## 4. Padrões de Interface & Experiência de Uso (Estilo Waze)
- **Barra de Navegação Turn-by-Turn**:
  - Card flutuante superior com a próxima manobra, distância restante e ícone do piso de destino.
- **Seletor Rápido de Pisos (Floor Picker)**:
  - Controle vertical flutuante acessível pelo polegar direito para alternar rapidamente entre andares com indicação de onde o usuário ou o destino estão.
- **Bottom Sheet de Detalhes da Loja**:
  - Sheet interativo com snap points (`.presentationDetents([.fraction(0.18), .medium, .large])`) exibindo nome da loja, andar, horário, botão de "Traçar Rota" em destaque e comodidades próximas.
- **Feedback Háptico & Acessibilidade**:
  - `UIImpactFeedbackGenerator` ao selecionar lojas, mudar de andar ou iniciar navegação.
  - Rótulos e rotas com suporte a rotas acessíveis (priorizando elevadores sobre escadas).

## 5. Persistência Offline-First & Sincronização
- Todo o mapa, plantas dos pisos, lojas e grafo de roteamento do shopping selecionado devem estar disponíveis 100% offline via **SwiftData** ou cache local estruturado em JSON/vetorial.
- A navegação não deve travar se o usuário perder o sinal 4G/5G dentro do shopping.

