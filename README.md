# Sobe, Engenheiro! 👷‍♂️🏗️

Arcade de plataforma vertical feito na **Godot 4**. Um engenheiro mecânico que não para de correr precisa subir um prédio em obra, andar por andar, desviando de vergalhões, martelos e clientes pedindo "só mais uma alteração".

> **Status:** protótipo v0.2 — estilo Leap Day: mais rápido, visual caricato, pisão em inimigos,
> placas de segurança (checkpoints), 5 andares com 13 tipos de obstáculo de obra.
> A arte é desenhada por código (formas com contorno); sprites de verdade chegam na Etapa 4.

Documento de design completo: [`docs/GDD.md`](docs/GDD.md)

---

## 1. Como jogar no seu computador

1. Baixe a **Godot 4.3 ou mais nova** em <https://godotengine.org/download> — escolha a versão normal (**não** a ".NET").
2. Baixe este projeto: no GitHub, botão verde **Code → Download ZIP**, e descompacte.
3. Abra a Godot → **Importar** → selecione o arquivo `project.godot` desta pasta → **Importar e Editar**.
4. Aperte **F5** (ou o botão ▶ no canto superior direito).

Na primeira vez a Godot demora alguns segundos importando. Se aparecer um aviso sobre versão, clique em **OK/Converter**.

### Controles

| Ação | PC | Celular | Controle |
|---|---|---|---|
| Pular / pulo duplo / pulo de parede | Espaço, W, ↑, Z, J ou clique | tocar na tela | A |
| Reiniciar o andar | R | — | Y |
| Pausar | Esc ou P | — | Start |
| Pular para o próximo andar (só no editor) | N | — | — |

**Dicas:** ele corre sozinho e vira ao bater na parede. No ar, encostar numa parede faz ele **agarrar**; toque de novo para **pular da parede**. Caia na cabeça do **cliente** e do **pombo** para derrotá-los. Ao morrer você volta para a última **placa de segurança** verde.

---

## 2. Como colocar no seu GitHub

### Jeito fácil (pelo site)
1. Entre em <https://github.com/new>, dê o nome `sobe-engenheiro` e clique em **Create repository**.
2. Na página do repositório vazio, clique em **uploading an existing file**.
3. Arraste **todo o conteúdo** desta pasta (inclusive a pasta `.github`) e clique em **Commit changes**.
   - Se o seu sistema esconde a pasta `.github`, use o jeito com Git abaixo.

### Jeito com Git (recomendado)
Instale o Git (<https://git-scm.com>), abra um terminal **dentro desta pasta** e rode:

```bash
git remote add origin https://github.com/SEU_USUARIO/sobe-engenheiro.git
git branch -M main
git push -u origin main
```

(O repositório já vem com o primeiro commit feito. Se você baixou só os arquivos, rode antes `git init`, `git add .` e `git commit -m "Protótipo inicial"`.)

### Teste automático no GitHub
Depois do envio, abra a aba **Actions** do repositório. O teste **"Teste do jogo"** baixa a Godot, abre todos os andares e simula alguns segundos de jogo.
- ✅ verde = nenhum script com erro.
- ❌ vermelho = clique nele para ver qual arquivo e linha deram problema (me mande essa mensagem).

Para rodar o mesmo teste no seu PC:
```bash
godot --headless --path . -- --teste
```

---

## 3. Estrutura do projeto

```
project.godot                  configurações (resolução, autoload, renderizador)
scenes/
  main.tscn                    cena inicial
  player.tscn                  o engenheiro (ajuste a física no Inspetor!)
scripts/
  main.gd                      troca de andar, morte, vitória, pausa, teste
  autoload/game.gd             controles, progresso, recordes, salvamento
  player/player.gd             movimentação e desenho do engenheiro
  level/level.gd               monta o andar a partir do mapa de texto
  level/level_camera.gd        câmera vertical
  level/construction_background.gd   fundo da obra
  levels/level_data.gd         OS MAPAS DOS ANDARES
  objects/                     parafuso, porta, vergalhão, martelo, cliente, plataformas
  ui/hud.gd                    textos na tela
  util/shapes.gd               ajuda para criar colisões
docs/GDD.md                    documento de design
.github/workflows/teste.yml    teste automático
```

---

## 4. Mexendo no jogo (sem medo)

### Ajustar a sensação do pulo
Abra `scenes/player.tscn`, clique no nó **Player** e veja o **Inspetor** à direita: velocidade, força do pulo, gravidade, tempo agarrado na parede etc. Mude, aperte F5 e sinta a diferença. Para voltar ao valor original, clique na setinha ↺ ao lado do campo.

### Criar ou editar um andar
Abra `scripts/levels/level_data.gd`. Cada andar é um desenho em texto com **20 caracteres por linha**:

```
CENÁRIO   #  concreto   =  viga de aço   -  andaime (atravessa por baixo)
          C  tábua podre   M  viga no guindaste   V  elevador   J  pneu-mola
COISAS    P  início   E  capacete de ouro (fim)   o  porca   !  placa de segurança
PERIGOS   ^  vergalhão          H  martelo (cai quando você passa embaixo)
          K  cliente (pisável)  W  peão com carrinho (não pisável)
          A  pombo (pisável)    D  drone da fiscalização
          S  serra no trilho    ~  cabo com faísca    X  bate-estaca
```

Regras de ouro: até **3 linhas** entre plataformas = pulo simples; **4–6 linhas** = pulo duplo; **7–8** = só com pneu-mola; poço para escalar parede = **3 colunas** de largura. O arquivo `tools/gen_levels.py` gera e confere os mapas (opcional, precisa de Python). Se um mapa tiver erro (linha com tamanho errado, sem `P` ou sem `E`), aparece uma mensagem vermelha na aba **Saída** da Godot.

---

## 5. Próximos passos

- [ ] **Você:** jogar os 5 andares e me dizer onde ficou fácil, difícil ou estranho
- [ ] Etapa 3: mais perigos de obra (solda, cabo energizado, encarregado)
- [ ] Etapa 4: sprites em pixel art, sons e música, andares 6–10
- [ ] Etapa 5: menu, seleção de andar, loja de capacetes
- [ ] Etapa 6: botões na tela, exportação Android e Windows

## Créditos

Código e arte originais. Inspirado na sensação de movimento de jogos arcade de plataforma vertical; nenhum asset de outros jogos é usado.
