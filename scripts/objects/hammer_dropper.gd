class_name HammerDropper
extends Node2D
## Martelo pendurado (estilo "estalactite" do Leap Day): quando o
## engenheiro passa EMBAIXO, treme um instante e despenca. Volta depois.

enum S { READY, SHAKE, EMPTY }

var level: Level
var shake_time: float = 0.28
var respawn_time: float = 2.2
var kill_y: float = 100000.0

var _s: S = S.READY
var _timer: float = 0.0
var _t: float = 0.0


func _ready() -> void:
	z_index = 2


func _physics_process(delta: float) -> void:
	_t += delta
	match _s:
		S.READY:
			if level != null and is_instance_valid(level.player) and not level.player.is_dead():
				var p: Vector2 = level.player.global_position
				if absf(p.x - global_position.x) < 22.0 and p.y > global_position.y:
					_s = S.SHAKE
					_timer = shake_time
		S.SHAKE:
			_timer -= delta
			if _timer <= 0.0:
				_drop()
		S.EMPTY:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.READY
	queue_redraw()


func _drop() -> void:
	var h := Hammer.new()
	h.position = position + Vector2(0, 8)
	h.kill_y = kill_y
	get_parent().add_child(h)
	_s = S.EMPTY
	_timer = respawn_time


func _draw() -> void:
	# gancho preso no teto
	Toon.rect(self, Rect2(-5, -8, 10, 3), Color("fbc02d"))
	draw_line(Vector2(0, -5), Vector2(0, 2), Color("8d6e63"), 1.0)
	if _s == S.EMPTY:
		return
	var shake: float = sin(_t * 70.0) * 1.5 if _s == S.SHAKE else 0.0
	draw_set_transform(Vector2(shake, 2), 0.0, Vector2.ONE)
	Hammer.draw_hammer(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _s == S.SHAKE:
		Toon.rect(self, Rect2(8, -6, 3, 6), Color("ff1744"))
		Toon.rect(self, Rect2(8, 2, 3, 2), Color("ff1744"))
