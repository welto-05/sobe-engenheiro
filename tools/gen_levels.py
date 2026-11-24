"""Gera scripts/levels/level_data.gd (v0.2, estilo Leap Day) e valida."""
import sys

W = 20
TOP = "#" * W
BLANK = "#" + " " * 18 + "#"


class F:
    def __init__(self, rows):
        self.m = [list(BLANK) for _ in range(rows)]
        self.m[0] = list(TOP)
        self.m[-1] = list(TOP)

    def plat(self, r, a, b, ch="-"):
        for c in range(a, b + 1):
            self.m[r][c] = ch
        return self

    def put(self, r, c, ch):
        self.m[r][c] = ch
        return self

    def col(self, c, r1, r2, ch="#"):
        for r in range(r1, r2 + 1):
            self.m[r][c] = ch
        return self

    def rows(self):
        return ["".join(x) for x in self.m]


# ---------------- ANDAR 1 : Primeiro dia ----------------
def floor1():
    f = F(64)
    f.put(62, 3, "P")
    tiers = [
        (60, 10, 18), (57, 1, 9), (54, 9, 18), (51, 1, 10), (48, 6, 13), (45, 11, 18),
        (42, 1, 8), (39, 10, 18), (36, 1, 10), (33, 8, 18), (30, 1, 9), (27, 6, 15),
        (24, 11, 18), (21, 1, 10), (18, 9, 18), (15, 1, 9), (12, 5, 14), (9, 10, 18), (6, 1, 9),
    ]
    for r, a, b in tiers:
        f.plat(r, a, b)
    for r, c in [(56, 5), (44, 15), (32, 12), (20, 4), (11, 9), (8, 14)]:
        f.put(r, c, "o")
    f.put(53, 14, "K")   # primeiro cliente: pise na cabeça!
    f.put(35, 6, "K")
    f.put(17, 13, "K")
    f.put(47, 9, "!")
    f.put(26, 10, "!")
    f.put(41, 3, "J")    # pneu-mola: atalho
    f.put(5, 5, "E")
    return f.rows()


# ---------------- ANDAR 2 : Pulo duplo, vergalhões e pombos ----------------
def floor2():
    f = F(66)
    f.put(64, 3, "P")
    f.put(64, 8, "^").put(64, 9, "^")
    tiers = [
        (62, 10, 18), (57, 1, 9), (52, 8, 18), (47, 1, 10), (42, 9, 18), (37, 1, 9),
        (34, 6, 18), (29, 1, 10), (24, 9, 18), (19, 1, 9), (16, 8, 15), (11, 1, 10),
        (8, 10, 18), (4, 1, 9),
    ]
    for r, a, b in tiers:
        f.plat(r, a, b)
    for r, c in [(56, 4), (36, 5), (18, 3), (7, 14), (45, 14)]:
        f.put(r, c, "o")
    f.put(51, 15, "^").put(51, 16, "^")
    f.put(36, 8, "^")
    f.put(23, 13, "^").put(23, 14, "^")
    f.put(46, 4, "!")
    f.put(28, 5, "!")
    f.put(44, 12, "A")
    f.put(26, 10, "A")
    f.put(41, 15, "K")
    f.put(15, 12, "K")
    f.put(3, 4, "E")
    return f.rows()


# ---------------- ANDAR 3 : Poço do elevador (paredes, martelos, cabos) ----------------
def floor3():
    f = F(62)
    f.put(60, 3, "P")
    f.plat(58, 1, 10).plat(55, 9, 18).plat(52, 1, 18)
    f.put(51, 3, "!")
    # poço A (direita): coluna na col 15
    f.col(15, 37, 49)
    f.plat(38, 8, 14)
    f.put(44, 17, "o")
    # meio
    f.plat(35, 1, 9)
    f.put(34, 3, "!")
    f.put(30, 5, "H")
    f.plat(32, 9, 18)
    f.plat(29, 9, 17, "~")
    f.put(31, 14, "o")
    # poço B (esquerda): coluna na col 4
    f.plat(27, 1, 9)
    f.col(4, 9, 23)
    f.plat(10, 5, 12, "=")
    f.col(13, 9, 9)
    f.put(16, 2, "o")
    f.put(9, 8, "!")
    f.plat(7, 8, 18)
    f.put(6, 15, "o")
    f.put(2, 12, "H")
    f.plat(4, 1, 9)
    f.put(3, 4, "E")
    f.put(57, 5, "o").put(54, 14, "o")
    return f.rows()


# ---------------- ANDAR 4 : Obra em movimento ----------------
def floor4():
    f = F(62)
    f.put(60, 3, "P")
    for c in (10, 11, 12):
        f.put(60, c, "^")
    f.plat(58, 13, 18)
    f.plat(55, 7, 10, "M")
    f.plat(52, 1, 6)
    f.put(51, 3, "o")
    f.plat(49, 7, 12, "C")
    f.plat(46, 13, 18)
    f.put(45, 16, "!")
    f.plat(43, 1, 12)
    f.plat(42, 3, 10, "S")
    f.plat(40, 13, 18)
    f.put(39, 15, "J")
    f.plat(33, 5, 14)
    f.put(32, 9, "o")
    f.plat(30, 1, 4, "V")
    f.plat(26, 8, 18)
    f.put(25, 12, "!")
    f.plat(23, 4, 7, "M")
    f.plat(20, 11, 16, "C")
    f.plat(17, 1, 8)
    f.plat(16, 2, 7, "S")
    f.plat(14, 10, 18)
    f.put(13, 15, "K")
    f.plat(11, 2, 9)
    f.put(10, 5, "o")
    f.plat(8, 11, 14, "M")
    f.plat(5, 1, 8)
    f.put(4, 4, "E")
    return f.rows()


# ---------------- ANDAR 5 : Hora do rush ----------------
def floor5():
    f = F(66)
    f.put(64, 3, "P")
    f.plat(62, 9, 18)
    f.put(61, 14, "W")
    f.plat(59, 1, 9)
    f.put(55, 5, "X")
    f.plat(56, 11, 18)
    f.plat(53, 1, 8)
    f.put(52, 3, "!")
    f.plat(50, 9, 18)
    f.put(46, 8, "D")
    f.plat(47, 1, 8)
    f.put(44, 4, "H")
    f.plat(44, 10, 18)
    f.put(43, 14, "K")
    f.plat(41, 1, 9)
    f.plat(39, 4, 15, "~")
    f.plat(38, 10, 18)
    f.plat(35, 1, 9)
    f.put(34, 4, "!")
    f.plat(32, 4, 15)
    f.put(28, 7, "X").put(28, 12, "X")
    f.plat(27, 1, 5)
    f.plat(24, 8, 18)
    f.put(23, 12, "W")
    # poço final (direita)
    f.col(15, 8, 19)
    f.plat(9, 9, 14)
    f.plat(6, 1, 9)
    f.put(5, 5, "E")
    f.put(4, 12, "D")
    for r, c in [(61, 4), (55, 15), (49, 15), (31, 10), (23, 16), (14, 17), (5, 7)]:
        f.put(r, c, "o")
    return f.rows()


FLOORS = [
    ("Primeiro dia de obra", "Toque para pular. Caia na cabeça do cliente para tirá-lo do caminho!", floor1()),
    ("Pulo duplo e pombos", "Pule de novo no ar. Pombos dá para pisar; vergalhão não!", floor2()),
    ("Poço do elevador", "Encoste na parede no ar e pule para escalar. Cuidado com a faísca no cabo.", floor3()),
    ("Obra em movimento", "Pneu lança alto, tábua podre cai, serra não perdoa.", floor4()),
    ("Hora do rush", "Bate-estaca, drone da fiscalização e peão com carrinho. Boa sorte!", floor5()),
]

SOLID = set("#=")
GROUND = set("#=-C")
ALLOWED = set("#=-^PEoHKWADSX~JC!MV ")
NEEDS_GROUND = set("PE^KW!J")

ok = True
for name, tip, m in FLOORS:
    for i, line in enumerate(m):
        if len(line) != W:
            print(f"[{name}] linha {i} com {len(line)} colunas"); ok = False
        if set(line) - ALLOWED:
            print(f"[{name}] linha {i} caracteres inválidos {set(line) - ALLOWED}"); ok = False
        if line[0] not in SOLID or line[-1] not in SOLID:
            print(f"[{name}] linha {i} sem paredes"); ok = False
    flat = "".join(m)
    if flat.count("P") != 1 or flat.count("E") != 1:
        print(f"[{name}] precisa de 1 P e 1 E"); ok = False
    for r, line in enumerate(m):
        for c, ch in enumerate(line):
            if ch in NEEDS_GROUND and m[r + 1][c] not in GROUND:
                print(f"[{name}] '{ch}' em (linha {r}, col {c}) sem chão embaixo"); ok = False
            if ch == "X":
                n = 0
                while n < 7 and m[r + n + 1][c] not in GROUND:
                    n += 1
                if m[r + n + 1][c] not in GROUND:
                    print(f"[{name}] bate-estaca em ({r},{c}) sem chão até 7 linhas abaixo"); ok = False
    surf = [r for r, line in enumerate(m) if any(ch in "-CMV=" for ch in line[1:-1])]
    gaps = [b - a for a, b in zip(surf, surf[1:])]
    print(f"{name:26s} linhas={len(m):3d} parafusos={flat.count('o')} checkpoints={flat.count('!')} maior_vão={max(gaps)}")

if not ok:
    sys.exit(1)

out = ['## Mapas dos andares (gerado por tools/gen_levels2.py, mas pode editar à mão).',
       '## Cada linha precisa ter exatamente 20 caracteres.',
       '##',
       '## LEGENDA — cenário',
       '##   #  concreto          =  viga de aço         -  andaime (atravessa por baixo)',
       '##   C  tábua podre (cai) M  viga no guindaste   V  elevador de obra',
       '##   J  pneu-mola (lança bem alto)',
       '## LEGENDA — coisas',
       '##   P  início   E  elevador com o capacete de ouro (fim)',
       '##   o  parafuso  !  placa de segurança (checkpoint)',
       '## LEGENDA — perigos',
       '##   ^  vergalhão               H  martelo (cai quando você passa embaixo)',
       '##   K  cliente (pise na cabeça) W  peão com carrinho (NÃO dá para pisar)',
       '##   A  pombo (pise na cabeça)   D  drone da fiscalização (voa na diagonal)',
       '##   S  serra no trilho (sequência de S = trilho)',
       '##   ~  cabo energizado com faísca (sequência de ~ = cabo)',
       '##   X  bate-estaca (desce até o chão e sobe)',
       'class_name LevelData',
       'extends RefCounted',
       '',
       'const FLOORS: Array = [']
for name, tip, m in FLOORS:
    out += ['\t{', f'\t\t"name": "{name}",', f'\t\t"tip": "{tip}",', '\t\t"map": [']
    out += [f'\t\t\t"{line}",' for line in m]
    out += ['\t\t],', '\t},']
out.append(']')
open(sys.argv[1], "w", encoding="utf-8").write("\n".join(out) + "\n")
print("gerado")
