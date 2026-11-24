class_name CrumblePlatform
extends StaticBody2D
## Tábua podre: depois que o engenheiro pisa, treme e cai.
## Volta alguns segundos depois. Posição = canto superior esquerdo da célula.

enum S { IDLE, SHAKING, GONE }

var delay: float = 0.45     ## tempo entre pisar e cair
var respawn: float = 2.5    ## tempo para a tábua voltar

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
	# Sensor fininho logo acima da tábua para saber se alguém pisou.
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
		S.GONE:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.IDLE
				_shape.set_deferred("disabled", false)
	queue_redraw()


func _draw() -> void:
	if _s == S.GONE:
		# contorno tracejado mostrando onde a tábua vai voltar
		var alpha: float = 0.35 if _timer < 0.6 else 0.15
		for i in 4:
			draw_rect(Rect2(i * 4, 0, 2, 1), Color(1, 1, 1, alpha))
		return
	var off := Vector2.ZERO
	if _s == S.SHAKING:
		off.x = sin(_timer * 90.0) * 1.0
		off.y = 1.0
	draw_rect(Rect2(off.x, off.y, 16, 4), Color("8d6e3f"))
	draw_rect(Rect2(off.x, off.y + 3, 16, 1), Color("5d4527"))
	draw_rect(Rect2(off.x + 5, off.y, 1, 2), Color("3e2d18"))   # rachaduras
	draw_rect(Rect2(off.x + 6, off.y + 2, 1, 1), Color("3e2d18"))
	draw_rect(Rect2(off.x + 11, off.y + 1, 1, 2), Color("3e2d18"))
