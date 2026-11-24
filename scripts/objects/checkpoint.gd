class_name Checkpoint
extends Area2D
## Placa de segurança: ao passar, vira o novo ponto de recomeço.
## Posição = pés da placa (base no chão).

signal reached(pos: Vector2)

var active: bool = false
var _t: float = 0.0
var _pop: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 1
	Shapes.rect(self, Vector2(14, 22), Vector2(0, -11))
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if active or not (body is Player) or (body as Player).is_dead():
		return
	active = true
	_pop = 1.0
	Poof.spawn(get_parent(), position + Vector2(0, -14), Color("69f0ae"), 10.0)
	reached.emit(position)


func _process(delta: float) -> void:
	_t += delta
	_pop = maxf(_pop - delta * 3.0, 0.0)
	queue_redraw()


func _draw() -> void:
	# poste
	Toon.rect(self, Rect2(-1, -14, 2, 14), Color("90a4ae"))
	# placa (vermelha "PARE" -> verde "OK" quando ativada)
	var s: float = 1.0 + _pop * 0.4
	draw_set_transform(Vector2(0, -18), sin(_t * 3.0) * 0.08 if active else 0.0, Vector2(s, s))
	var col := Color("43a047") if active else Color("e53935")
	Toon.rect(self, Rect2(-7, -5, 14, 10), col)
	draw_rect(Rect2(-6, -4, 12, 1), Color(1, 1, 1, 0.35))
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(-7, 2.5), "OK" if active else "EPI", HORIZONTAL_ALIGNMENT_CENTER, 14, 7, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# cone na base
	Toon.poly(self, PackedVector2Array([Vector2(-4, 0), Vector2(4, 0), Vector2(1, -6), Vector2(-1, -6)]), Color("ff6d00"))
	draw_rect(Rect2(-2, -4, 4, 1), Color.WHITE)
