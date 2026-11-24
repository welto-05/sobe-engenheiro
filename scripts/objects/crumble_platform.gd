class_name CrumblePlatform
extends StaticBody2D
## Tábua podre: depois que o engenheiro pisa, treme e cai.
## Volta alguns segundos depois. Posição = canto superior esquerdo da célula.

enum S { IDLE, SHAKING, GONE }

var delay: float = 0.35     ## tempo entre pisar e cair
var respawn: float = 2.2    ## tempo para a tábua voltar

var _s: S = S.IDLE
var _timer: float = 0.0
var _shape: CollisionShape2D
var _sensor: Area2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	z_index = 1
	_shape = Shapes.rect(self, Vector2(16, 6), Vector2(8, 3))
	_shape.one_way_collision = true
	_shape.one_way_collision_margin = 4.0
	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = 2
	_sensor.monitorable = false
	add_child(_sensor)
	Shapes.rect(_sensor, Vector2(14, 4), Vector2(8, -2))


func _physics_process(delta: float) -> void:
	match _s:
		S.IDLE:
			for body in _sensor.get_overlapping_bodies():
				if body is Player and (body as Player).is_on_floor():
					_s = S.SHAKING
					_timer = delay
		S.SHAKING:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.GONE
				_timer = respawn
				_shape.set_deferred("disabled", true)
				Poof.spawn(get_parent(), position + Vector2(8, 4), Color("a1887f"), 8.0)
		S.GONE:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.IDLE
				_shape.set_deferred("disabled", false)
	queue_redraw()


func _draw() -> void:
	if _s == S.GONE:
		var alpha: float = 0.45 if _timer < 0.6 else 0.18
		for i in 4:
			draw_rect(Rect2(i * 4 + 1, 1, 2, 2), Color(1, 1, 1, alpha))
		return
	var off := Vector2.ZERO
	if _s == S.SHAKING:
		off.x = sin(_timer * 90.0) * 1.2
		off.y = 1.0
	Toon.rect(self, Rect2(off.x + 0.5, off.y, 15, 5), Color("a1887f"))
	draw_rect(Rect2(off.x + 1, off.y, 14, 1), Color("d7ccc8"))
	draw_line(Vector2(off.x + 5, off.y), Vector2(off.x + 7, off.y + 3), Toon.OUTLINE, 1.0)
	draw_line(Vector2(off.x + 7, off.y + 3), Vector2(off.x + 6, off.y + 5), Toon.OUTLINE, 1.0)
	draw_line(Vector2(off.x + 11, off.y + 1), Vector2(off.x + 12, off.y + 4), Toon.OUTLINE, 1.0)
