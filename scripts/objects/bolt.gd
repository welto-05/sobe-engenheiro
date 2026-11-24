class_name Bolt
extends Area2D
## Porca/parafuso colecionável. Futuramente vira moeda da loja de capacetes.

signal collected

var _t: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 2
	Shapes.circle(self, 6.0, Vector2.ZERO)
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	_t = position.x * 0.05


func _process(delta: float) -> void:
	_t += delta
	position.y = _base_y + sin(_t * 3.0) * 2.0
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not (body as Player).is_dead():
		collected.emit()
		queue_free()


func _draw() -> void:
	var pts := PackedVector2Array()
	var squash: float = absf(cos(_t * 2.0)) * 0.6 + 0.4   # "gira" achatando
	for i in 6:
		var a: float = TAU * i / 6.0
		pts.append(Vector2(cos(a) * 5.0 * squash, sin(a) * 5.0))
	draw_colored_polygon(pts, Color("cfd8dc"))
	draw_rect(Rect2(-1.0 * squash - 0.5, -2, 2.0 * squash + 1.0, 4), Color("546e7a"))
	draw_rect(Rect2(-3.0 * squash, -4, 1, 1), Color.WHITE)
