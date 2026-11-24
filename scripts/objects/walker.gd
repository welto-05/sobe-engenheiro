class_name Walker
extends Enemy
## Anda pela plataforma e vira na beirada ou na parede (estilo Leap Day).
##   kind = "client" -> Cliente com prancheta. Lento. DÁ para pisar na cabeça.
##   kind = "worker" -> Peão com carrinho de mão cheio de tijolo. Rápido.
##                      NÃO dá para pisar (os tijolos machucam!).

const PHRASES := ["MUDA ISSO?", "E SE FOSSE AZUL?", "SÓ UM DETALHE!", "PRA ONTEM!", "CABE MAIS UM ANDAR?", "TIRA ESSA VIGA?"]

var kind: String = "client"
var speed: float = 32.0
var _dir: int = 1
var _t: float = 0.0
var _phrase: String = ""


func _setup() -> void:
	z_index = 3
	if kind == "worker":
		stompable = false
		speed = 58.0
		stomp_top = -16.0
		Shapes.rect(self, Vector2(16, 14), Vector2(0, -7))
	else:
		stompable = true
		speed = 32.0
		stomp_top = -18.0
		poof_color = Color("b39ddb")
		Shapes.rect(self, Vector2(10, 16), Vector2(0, -8))
	var idx: int = int(absf(position.x * 3.0 + position.y)) % PHRASES.size()
	_phrase = PHRASES[idx]
	_dir = 1 if idx % 2 == 0 else -1
	_t = float(idx)


func _physics_process(delta: float) -> void:
	_t += delta
	var half: float = 8.0 if kind == "worker" else 5.0
	var front := Vector2(position.x + _dir * (half + 1.0), position.y)
	# Vira se acabar o chão à frente ou se tiver parede.
	if not ground_at(front + Vector2(0, 2)) or solid_at(front + Vector2(0, -4)):
		_dir = -_dir
	position.x += _dir * speed * delta
	queue_redraw()


func _draw() -> void:
	var f: float = float(_dir)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, 1.0))
	var step: float = 1.0 if int(_t * 10.0) % 2 == 0 else -1.0
	if kind == "worker":
		_draw_worker(step)
	else:
		_draw_client(step)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if kind == "client" and fmod(_t, 4.0) < 2.2:
		_draw_bubble()


func _draw_client(step: float) -> void:
	# pernas finas
	Toon.rect(self, Rect2(-3 + step, -4, 2, 4), Color("37474f"))
	Toon.rect(self, Rect2(1 - step, -4, 2, 4), Color("37474f"))
	# terno roxo
	Toon.rect(self, Rect2(-4, -10, 8, 6), Color("8e5bd6"))
	draw_rect(Rect2(0, -10, 1, 4), Color("e53935"))   # gravata
	# cabeção careca com topete
	Toon.circle(self, Vector2(0, -15), 5.0, Color("f1b48e"))
	Toon.rect(self, Rect2(-4, -21, 6, 2), Color("3e2723"))
	Toon.eye(self, Vector2(1, -16), 1.8, Vector2(1, 0))
	Toon.eye(self, Vector2(4, -16), 1.6, Vector2(1, 0))
	Toon.brow(self, Vector2(2.5, -18.5), 5.0, 1.0)
	draw_rect(Rect2(2, -12, 3, 1), Toon.OUTLINE)   # boca reta de "não gostei"
	# prancheta
	Toon.rect(self, Rect2(4, -10, 5, 6), Color("c99a5b"))
	draw_rect(Rect2(5, -9, 3, 4), Color("eceff1"))
	draw_line(Vector2(5, -8), Vector2(8, -8), Color("90a4ae"), 1.0)
	draw_line(Vector2(5, -6), Vector2(7, -6), Color("90a4ae"), 1.0)


func _draw_worker(step: float) -> void:
	# carrinho de mão com tijolos (vai na frente)
	Toon.rect(self, Rect2(1, -9, 9, 5), Color("546e7a"))
	Toon.rect(self, Rect2(2, -12, 3, 3), Color("d84315"))
	Toon.rect(self, Rect2(5, -12, 3, 3), Color("bf360c"))
	Toon.rect(self, Rect2(3, -14, 3, 2), Color("d84315"))
	Toon.circle(self, Vector2(8, -3), 2.5, Color("263238"))
	draw_circle(Vector2(8, -3), 1.0, Color("90a4ae"))
	# peão
	Toon.rect(self, Rect2(-7 + step * 0.5, -4, 2, 4), Color("5d4037"))
	Toon.rect(self, Rect2(-4 - step * 0.5, -4, 2, 4), Color("5d4037"))
	Toon.rect(self, Rect2(-8, -10, 6, 6), Color("43a047"))   # camiseta verde
	Toon.rect(self, Rect2(-3, -9, 5, 2), Color("ffc29a"))   # braços no carrinho
	Toon.circle(self, Vector2(-5, -14), 4.0, Color("c68642"))
	Toon.rect(self, Rect2(-9, -18, 8, 2), Color("eceff1"))  # capacete branco
	Toon.circle(self, Vector2(-5, -18), 3.0, Color("eceff1"))
	Toon.eye(self, Vector2(-3, -14), 1.5, Vector2(1, 0))
	draw_rect(Rect2(-4, -11, 3, 1), Toon.OUTLINE)


func _draw_bubble() -> void:
	var font: Font = ThemeDB.fallback_font
	var fs: int = 8
	var tw: float = font.get_string_size(_phrase, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var box := Rect2(-tw * 0.5 - 3.0, -36.0, tw + 6.0, 11.0)
	draw_rect(box.grow(1.0), Toon.OUTLINE)
	draw_rect(box, Color.WHITE)
	draw_colored_polygon(PackedVector2Array([Vector2(-2, -25), Vector2(3, -25), Vector2(0, -21)]), Color.WHITE)
	draw_string(font, Vector2(-tw * 0.5, -28.0), _phrase, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Toon.OUTLINE)
