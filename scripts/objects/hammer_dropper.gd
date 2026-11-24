class_name HammerDropper
extends Node2D
## Martelo pendurado numa corda. Treme por um instante (aviso) e cai.
## Padrão fixo e previsível: o jogador aprende o ritmo.

var interval: float = 2.4      ## segundos entre cada martelo
var warn_time: float = 0.55    ## tempo tremendo antes de cair
var phase: float = 0.0         ## atraso inicial (para não caírem todos juntos)
var kill_y: float = 100000.0

var _t: float = 0.0
var _hidden: float = 0.0


func _ready() -> void:
	z_index = 2
	_t = phase


func _physics_process(delta: float) -> void:
	_t += delta
	_hidden = maxf(_hidden - delta, 0.0)
	if _t >= interval:
		_t -= interval
		_drop()
	queue_redraw()


func _drop() -> void:
	var h := Hammer.new()
	h.position = position + Vector2(0, 6)
	h.kill_y = kill_y
	get_parent().add_child(h)
	_hidden = 0.7


func _draw() -> void:
	# suporte e corda
	draw_rect(Rect2(-6, -8, 12, 3), Color("fbc02d"))
	draw_rect(Rect2(-6, -6, 12, 1), Color("f57f17"))
	draw_line(Vector2(0, -5), Vector2(0, 1), Color("bcaaa4"), 1.0)
	if _hidden > 0.0:
		return
	var shake := 0.0
	if _t > interval - warn_time:
		shake = sin(_t * 70.0) * 1.5
		draw_rect(Rect2(6, -6, 2, 5), Color("ff5252"))   # "!" de aviso
		draw_rect(Rect2(6, 0, 2, 2), Color("ff5252"))
	draw_rect(Rect2(-1 + shake, 1, 2, 7), Color("a1662f"))
	draw_rect(Rect2(-4 + shake, 1, 8, 3), Color("78909c"))
