# Sobe, Engenheiro! — Game Design Document (v0.2)

> Documento vivo. Atualize sempre que uma decisão mudar.

## 1. Identidade

| Item | Definição |
|---|---|
| **Nome** | **Sobe, Engenheiro!** (alternativas: *Prazo Final*, *Obra Alta*, *Nível Acima*) |
| **Gênero** | Arcade de plataforma 2D vertical, um botão |
| **Plataformas** | Android (retrato) e Windows |
| **Engine** | Godot 4.3+ / GDScript / renderizador *Compatibility* |
| **Público** | Jogadores casuais de celular que gostam de desafio de reflexo; partidas de 30 s a 2 min |
| **Tom** | Humor do dia a dia de obra: cliente pedindo alteração, encarregado atrapalhando, prazo apertado |

**Pitch:** um engenheiro mecânico que não para de correr precisa subir um prédio em construção, andar por andar, pulando andaimes, escalando poços de elevador e desviando de martelos, faíscas e clientes com prancheta.

**Pilares**
1. **Controle preciso** — um toque e uma reação previsível. Quem morre sabe por que morreu.
2. **Ritmo** — fases curtas, reinício em menos de 1 segundo.
3. **Subir dá gosto** — câmera, cenário e número do andar deixam claro que você está cada vez mais alto.
4. **Humor de obra** — perigos que qualquer engenheiro reconhece.

> Inspiração de *sensação* de movimento em Leap Day (Nitrome). Nenhum personagem, sprite, cenário, som ou nome é copiado: toda a arte e o conteúdo são originais.

## 2. Mecânicas (v0.2 — mais rápido, estilo Leap Day)

Medidas em pixels; um bloco = 16 px. Todos os números ficam no Inspetor de `scenes/player.tscn`.

| Mecânica | Comportamento | Valor |
|---|---|---|
| Corrida automática | Velocidade constante | 140 px/s (atravessa o andar em ~2 s) |
| Virar na parede | Bateu numa parede **no chão** → inverte a direção | — |
| Pulo | Altura fixa (previsível no toque) | −400 px/s → ~3,5 blocos |
| Pulo duplo | 1 vez no ar, recarrega no chão, na parede, ao pisar inimigo ou na mola | −350 px/s → total ~6 blocos |
| Pisão | Cair na cabeça de inimigo "pisável" derrota e quica | −380 px/s |
| Pneu-mola | Lança muito alto | −620 px/s → ~8,5 blocos |
| Agarrar parede | Bateu numa parede **no ar** → segura um instante | 0,15 s |
| Escorregar / pulo de parede | Desce devagar; pulo sai para o lado oposto | 70 px/s / −400 px/s |
| Gravidade / queda máx. | Mais "pesada" = pulos mais rápidos e secos | 1400 px/s² / 520 px/s |
| Coyote time / jump buffer | Tolerâncias invisíveis para o toque | 0,08 s / 0,12 s |
| Checkpoints | Placas de segurança a cada ~20 linhas; morrer volta para a última | reinício em 0,55 s |

**Regras para desenhar fases**
- Até **3 linhas** entre plataformas = pulo simples; **4–6 linhas** = pulo duplo; **7–8** = só com pneu-mola.
- Poço para escalar com pulo de parede: **3 colunas** de largura.
- Uma placa de segurança `!` a cada 15–25 linhas.

**Estilo visual (caricato)**: personagens com cabeça grande, olhos enormes, contorno escuro de 1 px, achatar/esticar ao pular e pousar, cores saturadas; blocos com contorno só nas bordas expostas; céu que muda de cor conforme sobe (dia → pôr do sol).

## 3. Câmera e resolução

- Resolução base **320 × 568** (retrato, 20 blocos de largura).
- Esticamento `canvas_items` + `keep_width`: a largura é sempre o andar inteiro; celulares mais altos enxergam mais para cima. No PC a janela abre em 405 × 720 com faixas laterais.
- Câmera segue só na **vertical**, olhando 40 px acima do jogador, com suavização; respeita os limites do andar.

## 4. Estrutura dos andares

Cada andar é uma fase de ~40–60 blocos de altura, do chão (`P`) até a porta do elevador (`E`). Os andares são escritos como texto (ver legenda em `scripts/levels/level_data.gd`), o que torna fácil criar e testar fases.

| Bloco | Andares | Tema | Mecânica nova |
|---|---|---|---|
| 1 | 1–5 | Fundação e térreo | corrida, pulo, pulo duplo, parede, plataformas móveis, primeiro cliente |
| 2 | 6–10 | Estrutura metálica | vigas suspensas por guindaste, estruturas instáveis |
| 3 | 11–15 | Elétrica e tubulação | cabos energizados liga/desliga, vapor de tubulação |
| 4 | 16–20 | Máquinas | solda com faíscas, esmerilhadeira, engrenagens, plataformas elevatórias |
| 5 | 21–25 | Cobertura | combinação de tudo, vento, desafios de precisão |

**Andares especiais** (a cada 5): "Vistoria" — o encarregado persegue de baixo para cima e a câmera sobe sozinha.

**Protótipo atual (Andares 1–5)**

| Andar | Nome | Ensina |
|---|---|---|
| 1 | Primeiro dia de obra | pulo, pisão no cliente, checkpoint, pneu-mola |
| 2 | Pulo duplo e pombos | pulo duplo, vergalhões, pombos |
| 3 | Poço do elevador | pulo de parede, martelo por gatilho, faísca no cabo |
| 4 | Obra em movimento | vigas móveis, elevador, tábua podre, serra, pneu obrigatório |
| 5 | Hora do rush | bate-estaca, drone, peão com carrinho + revisão |

## 5. Obstáculos (padrão Leap Day, tema de obra)

| Leap Day (tipo) | No nosso jogo | Letra | Pisável? | Padrão |
|---|---|---|---|---|
| Espinhos | Vergalhão exposto | `^` | não | fixo |
| Inimigo que anda e vira na beirada | Cliente com prancheta ("MUDA ISSO?") | `K` | **sim** | anda devagar |
| Inimigo com casco de espinhos | Peão com carrinho de tijolos | `W` | não | anda rápido |
| Inimigo voador | Pombo de obra | `A` | **sim** | voa de parede a parede |
| Inimigo que flutua na diagonal | Drone da fiscalização | `D` | não | quica dentro de uma área |
| Serra em trilho | Serra circular | `S` | não | vai e volta no trilho |
| Bola de energia em fio | Faísca no cabo energizado | `~` | não | corre de ponta a ponta |
| Bloco esmagador | Bate-estaca | `X` | não | espera, treme, desce, sobe |
| Estalactite | Martelo pendurado | `H` | não | cai quando você passa embaixo |
| Mola | Pneu-mola | `J` | — | lança muito alto |
| Plataforma que cai | Tábua podre | `C` | — | cai 0,35 s depois de pisar |
| Plataforma móvel | Viga no guindaste / elevador | `M` / `V` | — | vai e volta |
| Fruta | Porca dourada | `o` | — | colecionável |
| Checkpoint | Placa de segurança (EPI → OK) | `!` | — | ponto de recomeço |
| Taça de ouro | Capacete de ouro no elevador | `E` | — | fim do andar |

Planejado: encarregado que bloqueia a plataforma, furadeira na parede, jato de solda, carga de guindaste atravessando a tela, laje desmoronando.

## 6. Personagem

Engenheiro mecânico simpático: capacete amarelo, bigode, camisa azul, colete laranja refletivo, calça de trabalho e botas.
Animações: corrida (4 quadros), pulo, pulo duplo (giro), queda, agarrar, escorregar (poeira), morte (voa girando), comemoração (pulinhos).
No protótipo é desenhado por código (retângulos). Na Etapa 4 vira sprite sheet 16×16 em `assets/sprites/`.

## 7. Visual e som

- Pixel art, blocos de 16 px, paleta noturna fria no fundo e cores quentes/saturadas no que é interativo (amarelo = atenção, vermelho = perigo, verde = saída).
- Fundo: laje, pilares, vãos de janela com céu, tubulação, número do andar pintado.
- Som (Etapa 4): passos, pulo, pulo duplo, agarrar, parafuso, morte cômica, porta do elevador; música chiptune com batida de obra.

## 8. Controles

| Ação | Celular | PC | Controle |
|---|---|---|---|
| Pular / pulo duplo / pulo de parede | tocar em qualquer lugar | Espaço, W, ↑, Z, J ou clique | A / B |
| Reiniciar andar | (botão na Etapa 6) | R | Y |
| Pausar | sai do app = pausa | Esc / P | Start |

Agarrar a parede é **automático** (encostar no ar), então o jogo continua sendo de um botão só.

## 9. Arquitetura (Godot)

```
Main (Node, main.gd)            -> troca andares, morte, vitória, pausa, teste
├── Hud (CanvasLayer)           -> textos na tela
└── AndarXX (Level, level.gd)   -> criado por código a partir do mapa
    ├── ConstructionBackground  -> fundo desenhado
    ├── Solidos (StaticBody2D)  -> colisões juntadas em retângulos grandes
    ├── Andaimes (StaticBody2D) -> colisões "one-way"
    ├── objetos e perigos (Area2D / AnimatableBody2D)
    ├── Player (CharacterBody2D, scenes/player.tscn)
    └── LevelCamera (Camera2D)
Game (Autoload)                 -> controles, progresso, recordes, salvamento
```

Camadas de colisão: **1 = cenário**, **2 = jogador**. Perigos são `Area2D` que só "olham" a camada 2.

Máquina de estados do jogador: `GROUND → AIR ↔ WALL`, além de `DEAD` e `WIN`.

## 10. Sistemas futuros (ordem planejada)

1. Sons e música · 2. Menu principal e seleção de andar · 3. Loja de capacetes/roupas com parafusos · 4. Personagens desbloqueáveis (engenheira civil, eletricista, estagiário) · 5. Conquistas · 6. Controles configuráveis · 7. Botões na tela para celular e exportação Android/Windows.

## 11. Riscos e cuidados

- **Propriedade intelectual:** não usar nenhum asset, nome ou layout de fase de Leap Day ou outros jogos.
- **Dificuldade:** testar cada andar com pessoas que nunca jogaram; medir mortes por andar.
- **Desempenho:** colisões juntadas, nada de física pesada; meta de 60 FPS em celular intermediário.
