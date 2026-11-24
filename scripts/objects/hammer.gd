class_name Hammer
extends Hazard
## Martelo caindo. Quebra quando bate no cenário, mata quando bate no jogador.

var velocity := Vector2.ZERO
var fall_gravity: float = 1300.0
var max_speed: float = 480.0
var kill_y: float = 100000.0
var _rot: float = 0.0


func _setup() -> void:
	collision_mask = 3   # jogador (2) + cenário (1)
	z_index = 3
	Shapes.rect(self, Vector2(10, 10), Vector2(0, 4))


func _physics_process(delta: float) -> void:
	velocity.y = minf(velocity.y + fall_gravity * delta, max_speed)
	position += velocity * delta
	_rot += delta * 6.0
	queue_redraw()
	if position.y > kill_y:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()
	else:
		Poof.spawn(get_parent(), position + Vector2(0, 6), Color("bcaaa4"), 7.0)
		queue_free()


## Desenho reaproveitado pelo martelo pendurado.
static func draw_hammer(ci: CanvasItem) -> void:
	Toon.rect(ci, Rect2(-1.5, 0, 3, 9), Color("c47a3a"))
	Toon.rect(ci, Rect2(-6, 7, 12, 5), Color("90a4ae"))
	ci.draw_rect(Rect2(-5, 8, 10, 1), Color("eceff1"))


func _draw() -> void:
	draw_set_transform(Vector2(0, -2), sin(_rot) * 0.3, Vector2.ONE)
	draw_hammer(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
