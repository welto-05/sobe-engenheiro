# Sobe, Engenheiro! — Game Design Document (v0.1)

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

## 2. Mecânicas (valores atuais do protótipo)

Medidas em pixels; um bloco = 16 px. Todos os números ficam no Inspetor de `scenes/player.tscn`.

| Mecânica | Comportamento | Valor |
|---|---|---|
| Corrida automática | Velocidade constante, sem aceleração | 100 px/s (atravessa o andar em ~3 s) |
| Virar na parede | Bateu numa parede **no chão** → inverte a direção | — |
| Pulo | Altura fixa (previsível no toque) | −330 px/s → ~3,4 blocos |
| Pulo duplo | 1 vez no ar, recarrega no chão ou ao agarrar parede; corrige a trajetória | −290 px/s → total ~5,8 blocos |
| Coyote time | Ainda dá para pular logo depois de sair da beirada | 0,08 s |
| Jump buffer | Toque um pouco antes de pousar vale | 0,12 s |
| Agarrar parede | Bateu numa parede **no ar** → fica parado agarrado | 0,30 s |
| Escorregar | Depois do tempo agarrado, desce devagar | máx. 45 px/s |
| Pulo de parede | Sai para o lado oposto com impulso de pulo | −330 px/s |
| Gravidade / queda máx. | — | 1000 px/s² / 420 px/s |
| Pulo variável | Desligado por padrão (no toque, toques curtos geravam pulos curtos sem querer) | `variable_jump` |

**Regras para desenhar fases (derivadas da física)**
- Distância vertical entre plataformas: **até 3 blocos** = pulo simples; **4–5 blocos** = exige pulo duplo.
- Poço para escalar com pulo de parede: **3 blocos de largura** (cada pulo sobe ~3 blocos).
- Plataformas com pelo menos 4 blocos de largura (o engenheiro atravessa 3 blocos em meio segundo).

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
| 1 | Primeiro dia de obra | corrida automática, virar na parede, pulo |
| 2 | Pulo duplo e vergalhões | pulo duplo, perigo fixo |
| 3 | Poço do elevador | agarrar, escorregar e pulo de parede |
| 4 | Obra em movimento | plataformas móveis, elevador, tábua podre |
| 5 | O cliente chegou | perigos móveis com padrão (martelo, cliente) + revisão |

## 5. Obstáculos (todos com padrão aprendível)

| Categoria | Obstáculo | Padrão | Status |
|---|---|---|---|
| Ambiente | Vergalhão exposto `^` | fixo | ✅ |
| Ambiente | Tábua podre `C` | cai 0,45 s depois de pisar, volta em 2,5 s | ✅ |
| Ambiente | Vão / buraco | queda para o andaime de baixo | ✅ |
| Ferramenta | Martelo pendurado `H` | treme 0,55 s (aviso "!") e cai a cada 2,4 s | ✅ |
| Pessoa | Cliente com prancheta `K` | anda ±28 px; balão "MUDA ISSO?" | ✅ |
| Equipamento | Plataforma móvel `M` / elevador `V` | senoide, período 3,2 s / 3,6 s | ✅ |
| Pessoa | Encarregado | para na plataforma por 2 s e bloqueia | planejado |
| Pessoa | Trabalhador com carrinho | atravessa a plataforma em linha reta | planejado |
| Ferramenta | Furadeira na parede | liga/desliga em ciclo; não dá para agarrar quando ligada | planejado |
| Equipamento | Solda | jato de faíscas em ciclo de 3 tempos | planejado |
| Equipamento | Cabo energizado | liga/desliga com zumbido de aviso | planejado |
| Equipamento | Carga de guindaste | atravessa a tela com sombra antes | planejado |
| Ambiente | Estrutura desmoronando | blocos caem em sequência | planejado |

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
