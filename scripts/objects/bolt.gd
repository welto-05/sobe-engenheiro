class_name Bolt
extends Area2D
## Porca colecionável (o "fruta" do nosso jogo). Vira moeda da loja depois.

signal collected

var _t: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 2
	Shapes.circle(self, 7.0, Vector2.ZERO)
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
		Poof.spawn(get_parent(), position, Color("ffe082"), 7.0)
		queue_free()


func _draw() -> void:
	var squash: float = absf(cos(_t * 2.5)) * 0.65 + 0.35   # "gira"
	var pts := PackedVector2Array()
	for i in 6:
		var a: float = TAU * i / 6.0
		pts.append(Vector2(cos(a) * 6.0 * squash, sin(a) * 6.0))
	Toon.poly(self, pts, Color("ffca28"))
	draw_circle(Vector2.ZERO, 2.2 * squash + 0.3, Color("8d6e00"))
	draw_rect(Rect2(-3.5 * squash, -4, 1.5, 1.5), Color.WHITE)
