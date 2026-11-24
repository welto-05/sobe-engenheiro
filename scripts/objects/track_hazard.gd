class_name TrackHazard
extends Hazard
## Perigo que vai e volta num trilho horizontal.
##   kind = "saw"   -> serra circular rolando sobre a plataforma (S)
##   kind = "spark" -> faísca correndo num cabo energizado (~)
## O trilho/cabo é desenhado pelo Level; aqui só a peça que se move.

var kind: String = "saw"
var x_min: float = 0.0
var x_max: float = 0.0
var speed: float = 70.0
var _dir: int = 1
var _t: float = 0.0


func _setup() -> void:
	z_index = 3
	if kind == "spark":
		speed = 95.0
		Shapes.circle(self, 3.5, Vector2.ZERO)
	else:
		speed = 70.0
		Shapes.circle(self, 6.0, Vector2.ZERO)
	_dir = 1 if int(position.x) % 32 < 16 else -1


func _physics_process(delta: float) -> void:
	_t += delta
	position.x += _dir * speed * delta
	if position.x > x_max:
		position.x = x_max
		_dir = -1
	elif position.x < x_min:
		position.x = x_min
		_dir = 1
	queue_redraw()


func _draw() -> void:
	if kind == "spark":
		var pulse: float = 1.0 + sin(_t * 30.0) * 0.4
		draw_circle(Vector2.ZERO, 6.0 * pulse, Color(1.0, 0.95, 0.3, 0.35))
		Toon.circle(self, Vector2.ZERO, 3.5, Color("fff176"))
		draw_circle(Vector2.ZERO, 1.8, Color.WHITE)
		for i in 4:
			var a: float = _t * 12.0 + TAU * i / 4.0
			draw_line(Vector2(cos(a), sin(a)) * 4.0, Vector2(cos(a), sin(a)) * 8.0 * pulse, Color("ffeb3b"), 1.0)
		return
	# serra circular com dentes girando e carinha de má
	var rot: float = _t * 14.0 * _dir
	var teeth := PackedVector2Array()
	for i in 16:
		var a: float = rot + TAU * i / 16.0
		var r: float = 7.5 if i % 2 == 0 else 5.5
		teeth.append(Vector2(cos(a), sin(a)) * r)
	Toon.poly(self, teeth, Color("b0bec5"))
	Toon.circle(self, Vector2.ZERO, 4.0, Color("eceff1"))
	draw_circle(Vector2(-1.5, -0.5), 1.0, Toon.OUTLINE)
	draw_circle(Vector2(1.5, -0.5), 1.0, Toon.OUTLINE)
	draw_line(Vector2(-2, 1.8), Vector2(2, 1.8), Toon.OUTLINE, 1.0)
