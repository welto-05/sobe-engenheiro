class_name Hammer
extends Hazard
## Martelo caindo. Quebra quando bate no cenário, mata quando bate no jogador.

var velocity := Vector2.ZERO
var fall_gravity: float = 900.0
var max_speed: float = 360.0
var kill_y: float = 100000.0
var _rot: float = 0.0


func _setup() -> void:
	collision_mask = 3   # jogador (2) + cenário (1)
	z_index = 3
	Shapes.rect(self, Vector2(8, 8), Vector2.ZERO)


func _physics_process(delta: float) -> void:
	velocity.y = minf(velocity.y + fall_gravity * delta, max_speed)
	position += velocity * delta
	_rot += delta * 9.0
	queue_redraw()
	if position.y > kill_y:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()
	else:
		queue_free()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, _rot, Vector2.ONE)
	draw_rect(Rect2(-1, -2, 2, 7), Color("a1662f"))
	draw_rect(Rect2(-4, -5, 8, 3), Color("78909c"))
	draw_rect(Rect2(-4, -5, 8, 1), Color("b0bec5"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
