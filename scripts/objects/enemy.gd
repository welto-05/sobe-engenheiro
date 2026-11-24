class_name Enemy
extends Hazard
## Base dos inimigos (estilo Leap Day):
## - stompable = true  -> cair em cima da cabeça derrota o inimigo e quica
## - stompable = false -> mata encostando de qualquer lado
## A cabeça fica em position.y + stomp_top (valor negativo = acima).

var level: Level
var stompable: bool = true
var stomp_top: float = -14.0
var alive: bool = true
var poof_color := Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	if not alive or not (body is Player):
		return
	var p := body as Player
	if p.is_dead():
		return
	var head_y: float = global_position.y + stomp_top
	if stompable and p.velocity.y > 0.0 and p.global_position.y <= head_y + 10.0:
		_stomped(p)
	else:
		p.die()


func _stomped(p: Player) -> void:
	alive = false
	p.bounce(p.stomp_bounce)
	Poof.spawn(get_parent(), global_position + Vector2(0, stomp_top * 0.5), poof_color, 9.0)
	queue_free()


## Ajuda: o mapa tem chão (sólido ou andaime) nesta posição do mundo?
func ground_at(world: Vector2) -> bool:
	return level != null and level.is_ground_at(world)


func solid_at(world: Vector2) -> bool:
	return level != null and level.is_solid_at(world)
