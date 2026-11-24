class_name InspectionDrone
extends Enemy
## Drone da fiscalização: voa na diagonal dentro de uma área e quica
## nas bordas dela e nas paredes. Hélices em cima: NÃO dá para pisar.

var box := Vector2(44, 34)     ## metade da largura/altura da área de voo
var speed := Vector2(55, 45)
var _origin := Vector2.ZERO
var _vel := Vector2.ZERO
var _t: float = 0.0


func _setup() -> void:
	z_index = 3
	stompable = false
	Shapes.circle(self, 6.0, Vector2.ZERO)
	_origin = position
	_vel = speed
	if int(position.x) % 32 < 16:
		_vel.x = -_vel.x


func _physics_process(delta: float) -> void:
	_t += delta
	var next := position + _vel * delta
	if absf(next.x - _origin.x) > box.x or solid_at(Vector2(next.x + signf(_vel.x) * 8.0, position.y)):
		_vel.x = -_vel.x
	if absf(next.y - _origin.y) > box.y or solid_at(Vector2(position.x, next.y + signf(_vel.y) * 8.0)):
		_vel.y = -_vel.y
	position += _vel * delta
	queue_redraw()


func _draw() -> void:
	# braços e hélices
	draw_line(Vector2(-9, -5), Vector2(9, -5), Toon.OUTLINE, 2.0)
	var spin: float = absf(sin(_t * 40.0)) * 5.0 + 1.0
	for x in [-9.0, 9.0]:
		draw_rect(Rect2(x - spin, -8, spin * 2.0, 2), Color(0.85, 0.9, 0.95, 0.9))
	# corpo
	Toon.circle(self, Vector2.ZERO, 6.0, Color("eceff1"))
	draw_rect(Rect2(-6, 1, 12, 2), Color("ffca28"))
	# olho-câmera vigiando
	Toon.eye(self, Vector2(0, -1), 3.0, Vector2(signf(_vel.x), 0.3))
	# luz vermelha piscando
	if int(_t * 4.0) % 2 == 0:
		draw_circle(Vector2(0, -7), 1.5, Color("ff1744"))
