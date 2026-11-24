class_name PileDriver
extends Hazard
## Bate-estaca: bloco pesado pendurado que espera, treme (aviso),
## despenca até o chão, fica um instante e sobe devagar. Padrão fixo.
## Posição = canto superior da célula, no centro (x).

enum S { WAIT, FALL, HOLD, RISE }

var drop: float = 48.0       ## quanto desce (calculado pelo Level)
var wait_time: float = 1.3
var warn_time: float = 0.35
var phase: float = 0.0

var _s: S = S.WAIT
var _timer: float = 0.0
var _offset: float = 0.0
var _base_y: float = 0.0


func _setup() -> void:
	z_index = 4
	Shapes.rect(self, Vector2(14, 15), Vector2(0, 8))
	_base_y = position.y
	_timer = maxf(wait_time - phase, 0.1)


func _physics_process(delta: float) -> void:
	match _s:
		S.WAIT:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.FALL
		S.FALL:
			_offset = minf(_offset + 520.0 * delta, drop)
			if _offset >= drop:
				_s = S.HOLD
				_timer = 0.45
		S.HOLD:
			_timer -= delta
			if _timer <= 0.0:
				_s = S.RISE
		S.RISE:
			_offset = maxf(_offset - 75.0 * delta, 0.0)
			if _offset <= 0.0:
				_s = S.WAIT
				_timer = wait_time
	position.y = _base_y + _offset
	queue_redraw()


func _draw() -> void:
	var shake := 0.0
	if _s == S.WAIT and _timer < warn_time:
		shake = sin(_timer * 80.0) * 1.2
	# corrente até o ponto de apoio
	var y := -_offset
	while y < 0.0:
		draw_rect(Rect2(-1, y, 2, 3), Color("78909c"))
		y += 4.0
	Toon.rect(self, Rect2(-6, -3 - _offset, 12, 3), Color("455a64"))
	# bloco com faixas de atenção e cara brava
	var body := Rect2(-7 + shake, 0, 14, 15)
	Toon.rect(self, body, Color("ffc107"))
	draw_rect(Rect2(-7 + shake, 11, 14, 4), Toon.OUTLINE)
	draw_rect(Rect2(-6 + shake, 12, 3, 2), Color("ffc107"))
	draw_rect(Rect2(-1 + shake, 12, 3, 2), Color("ffc107"))
	draw_rect(Rect2(4 + shake, 12, 2, 2), Color("ffc107"))
	var look := Vector2(0, 1) if _s == S.WAIT else Vector2(0, -0.5)
	Toon.eye(self, Vector2(-3 + shake, 5), 2.2, look)
	Toon.eye(self, Vector2(3 + shake, 5), 2.2, look)
	Toon.brow(self, Vector2(-3 + shake, 2), 4.0, 1.0)
	Toon.brow(self, Vector2(3 + shake, 2), 4.0, -1.0)
