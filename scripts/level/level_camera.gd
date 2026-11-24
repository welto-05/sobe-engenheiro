class_name LevelCamera
extends Camera2D
## Câmera que segue o engenheiro só na vertical, mostrando um pouco mais
## do que está ACIMA dele (é para lá que ele vai).

var target: Node2D
var level_size := Vector2(320, 568)
var look_up: float = 56.0       ## quanto a câmera olha para cima do jogador
var follow_speed: float = 9.0   ## maior = segue mais rápido


func _ready() -> void:
	make_current()


func setup(new_target: Node2D, width: float, height: float) -> void:
	target = new_target
	level_size = Vector2(width, height)
	limit_left = 0
	limit_top = 0
	limit_right = int(width)
	limit_bottom = int(height)
	position = Vector2(width * 0.5, _target_y())
	reset_smoothing()


func _target_y() -> float:
	var half: float = get_viewport_rect().size.y * 0.5
	if level_size.y <= half * 2.0:
		return level_size.y * 0.5
	var y: float = position.y
	if is_instance_valid(target):
		y = target.global_position.y - look_up
	return clampf(y, half, level_size.y - half)


func _process(delta: float) -> void:
	position.x = level_size.x * 0.5
	if not is_instance_valid(target):
		return
	position.y = lerpf(position.y, _target_y(), 1.0 - exp(-follow_speed * delta))
