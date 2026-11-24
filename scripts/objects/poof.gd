class_name Poof
extends Node2D
## Efeito de "puf" cartoon (nuvenzinha que cresce e some).

var color := Color.WHITE
var duration: float = 0.35
var size: float = 10.0
var _t: float = 0.0


static func spawn(parent: Node, pos: Vector2, poof_color: Color, poof_size: float) -> void:
	var p := Poof.new()
	p.position = pos
	p.color = poof_color
	p.size = poof_size
	parent.add_child(p)


func _ready() -> void:
	z_index = 8


func _process(delta: float) -> void:
	_t += delta
	if _t >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k: float = _t / duration
	var r: float = size * (0.4 + k)
	var c := color
	c.a = 1.0 - k
	for i in 6:
		var a: float = TAU * i / 6.0 + k
		draw_circle(Vector2(cos(a), sin(a)) * r, size * 0.35 * (1.0 - k) + 1.0, c)
