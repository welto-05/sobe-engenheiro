class_name SpringTire
extends Area2D
## Pneu-mola: encostou (andando ou caindo) é lançado bem alto.
## Posição = canto superior esquerdo da célula (o pneu fica no chão dela).

var launch: float = -620.0   ## ~8,5 blocos de altura
var _squish: float = 0.0
var _cooldown: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 2
	Shapes.rect(self, Vector2(14, 8), Vector2(8, 12))


func _physics_process(delta: float) -> void:
	_squish = maxf(_squish - delta * 4.0, 0.0)
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _cooldown <= 0.0:
		for body in get_overlapping_bodies():
			if body is Player:
				var p := body as Player
				if not p.is_dead() and p.velocity.y > -60.0:
					p.bounce(launch)
					_squish = 1.0
					_cooldown = 0.25
					Poof.spawn(get_parent(), position + Vector2(8, 14), Color(1, 1, 1, 0.8), 6.0)
	queue_redraw()


func _draw() -> void:
	var h: float = 8.0 - _squish * 3.0
	var top: float = 16.0 - h
	# pneu (visto de lado) com mola em cima
	Toon.rect(self, Rect2(1, top + 2, 14, h - 2), Color("263238"))
	draw_rect(Rect2(3, top + 3, 10, 1), Color("546e7a"))
	draw_rect(Rect2(3, top + h - 3, 10, 1), Color("546e7a"))
	Toon.rect(self, Rect2(2, top, 12, 2), Color("ff5252"))
	draw_rect(Rect2(4, top, 2, 1), Color(1, 1, 1, 0.6))
