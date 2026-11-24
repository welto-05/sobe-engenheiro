class_name Client
extends Hazard
## Cliente com prancheta pedindo alteração de última hora.
## Anda de um lado para o outro. Encostar nele = começar de novo.

const PHRASES := [
	"MUDA ISSO?",
	"E SE FOSSE AZUL?",
	"SÓ UM DETALHE!",
	"PRA ONTEM, OK?",
	"TIRA ESSA VIGA?",
	"CABE MAIS UM ANDAR?",
]

var speed: float = 32.0
var patrol: float = 28.0   ## distância máxima para cada lado

var _origin_x: float = 0.0
var _dir: int = 1
var _t: float = 0.0
var _phrase: String = ""


func _setup() -> void:
	z_index = 3
	Shapes.rect(self, Vector2(8, 14), Vector2(0, -7))
	_origin_x = position.x
	var idx: int = int(absf(position.x * 3.0 + position.y)) % PHRASES.size()
	_phrase = PHRASES[idx]
	_t = float(idx)


func _physics_process(delta: float) -> void:
	_t += delta
	position.x += _dir * speed * delta
	if position.x > _origin_x + patrol:
		position.x = _origin_x + patrol
		_dir = -1
	elif position.x < _origin_x - patrol:
		position.x = _origin_x - patrol
		_dir = 1
	queue_redraw()


func _draw() -> void:
	var step: float = 1.0 if int(_t * 8.0) % 2 == 0 else 0.0
	# pernas
	draw_rect(Rect2(-3, -4, 2, 4 - step), Color("37474f"))
	draw_rect(Rect2(1, -4, 2, 3 + step), Color("37474f"))
	# terno e gravata
	draw_rect(Rect2(-4, -11, 8, 7), Color("7e57c2"))
	draw_rect(Rect2(0, -11, 1, 5), Color("e53935"))
	# cabeça e cabelo
	draw_rect(Rect2(-3, -16, 6, 5), Color("e0a27a"))
	draw_rect(Rect2(-3, -17, 6, 2), Color("3e2723"))
	var eye_x: float = 1.0 if _dir > 0 else -2.0
	draw_rect(Rect2(eye_x, -14, 1, 1), Color("212121"))
	# prancheta com o "projeto"
	var cx: float = 3.0 if _dir > 0 else -7.0
	draw_rect(Rect2(cx, -10, 4, 5), Color("c99a5b"))
	draw_rect(Rect2(cx + 1, -9, 2, 3), Color("eceff1"))
	# balão de fala (aparece e some)
	if fmod(_t, 4.0) < 2.2:
		var font: Font = ThemeDB.fallback_font
		var fs: int = 8
		var tw: float = font.get_string_size(_phrase, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var box := Rect2(-tw * 0.5 - 3.0, -32.0, tw + 6.0, 11.0)
		draw_rect(box, Color.WHITE)
		draw_rect(box, Color("212121"), false, 1.0)
		draw_colored_polygon(PackedVector2Array([Vector2(-2, -21), Vector2(2, -21), Vector2(0, -18)]), Color.WHITE)
		draw_string(font, Vector2(-tw * 0.5, -24.0), _phrase, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("212121"))
