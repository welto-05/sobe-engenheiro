class_name ExitDoor
extends Area2D
## Porta do elevador de obra: chegar nela conclui o andar.
## A posição fica nos "pés" da porta (base apoiada no chão).

signal reached

var _open: bool = false
var _t: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 1
	Shapes.rect(self, Vector2(12, 20), Vector2(0, -10))
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if _open:
		return
	if body is Player and not (body as Player).is_dead():
		_open = true
		reached.emit()


func _draw() -> void:
	# moldura
	draw_rect(Rect2(-10, -27, 20, 27), Color("37474f"))
	draw_rect(Rect2(-10, -27, 20, 2), Color("607d8b"))
	# portas (abrem ao chegar)
	var gap: float = 6.0 if _open else 0.0
	draw_rect(Rect2(-8, -24, 8 - gap, 24), Color("90a4ae"))
	draw_rect(Rect2(gap, -24, 8 - gap, 24), Color("90a4ae"))
	if _open:
		draw_rect(Rect2(-8 + 8 - gap, -24, gap * 2.0, 24), Color("fff59d"))
	draw_rect(Rect2(-1, -24, 2, 24), Color("546e7a"))
	# placa "SAÍDA" piscando
	var blink: bool = int(_t * 2.0) % 2 == 0
	var sign_color := Color("43a047") if blink or _open else Color("2e7d32")
	draw_rect(Rect2(-12, -38, 24, 9), sign_color)
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(-11, -31), "SAÍDA", HORIZONTAL_ALIGNMENT_CENTER, 22, 8, Color.WHITE)
