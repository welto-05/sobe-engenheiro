class_name Pigeon
extends Enemy
## Pombo de obra: voa de um lado para o outro, balançando.
## Vira ao chegar perto de uma parede. Dá para pisar na cabeça.

var speed: float = 48.0
var _dir: int = 1
var _t: float = 0.0
var _base_y: float = 0.0


func _setup() -> void:
	z_index = 3
	stompable = true
	stomp_top = -5.0
	poof_color = Color("cfd8dc")
	Shapes.rect(self, Vector2(12, 8), Vector2.ZERO)
	_base_y = position.y
	_t = position.x * 0.1
	_dir = 1 if int(position.x) % 32 < 16 else -1


func _physics_process(delta: float) -> void:
	_t += delta
	if solid_at(position + Vector2(_dir * 10.0, 0)):
		_dir = -_dir
	position.x += _dir * speed * delta
	position.y = _base_y + sin(_t * 4.0) * 5.0
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(float(_dir), 1.0))
	var flap: float = sin(_t * 22.0)
	# corpo gordinho
	Toon.circle(self, Vector2(0, 0), 5.0, Color("90a4ae"))
	Toon.circle(self, Vector2(4, -3), 3.5, Color("78909c"))
	draw_circle(Vector2(2, 1), 2.5, Color("80cbc4"))   # peito furta-cor
	# asa batendo
	Toon.poly(self, PackedVector2Array([Vector2(-3, -1), Vector2(2, -1), Vector2(-1, -1 - 6.0 * flap)]), Color("b0bec5"))
	# bico e olho
	Toon.poly(self, PackedVector2Array([Vector2(7, -4), Vector2(10, -3), Vector2(7, -2)]), Color("ffb300"))
	Toon.eye(self, Vector2(5, -4), 1.4, Vector2(1, 0))
	# pezinhos
	draw_line(Vector2(-1, 5), Vector2(-1, 7), Color("ff7043"), 1.0)
	draw_line(Vector2(2, 5), Vector2(2, 7), Color("ff7043"), 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
