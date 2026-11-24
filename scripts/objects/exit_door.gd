class_name ExitDoor
extends Area2D
## Elevador de obra com o CAPACETE DE OURO: chegar nele conclui o andar.
## A posição fica nos "pés" do elevador (base apoiada no chão).

signal reached

var _open: bool = false
var _t: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	z_index = 1
	Shapes.rect(self, Vector2(14, 22), Vector2(0, -11))
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if _open:
		return
	if body is Player and not (body as Player).is_dead():
		_open = true
		Poof.spawn(get_parent(), position + Vector2(0, -34), Color("ffd54f"), 14.0)
		reached.emit()


func _draw() -> void:
	# cabine
	Toon.rect(self, Rect2(-11, -28, 22, 28), Color("607d8b"))
	draw_rect(Rect2(-11, -28, 22, 3), Color("ffc107"))
	var gap: float = 7.0 if _open else 0.0
	if _open:
		draw_rect(Rect2(-9, -24, 18, 24), Color("fff59d"))
	draw_rect(Rect2(-9, -24, 9 - gap, 24), Color("b0bec5"))
	draw_rect(Rect2(gap, -24, 9 - gap, 24), Color("b0bec5"))
	if not _open:
		draw_rect(Rect2(-1, -24, 2, 24), Color("78909c"))
	# capacete de ouro flutuando e brilhando em cima
	var bob: float = sin(_t * 3.0) * 2.0
	var c := Vector2(0, -38 + bob)
	for i in 8:
		var a: float = _t * 1.5 + TAU * i / 8.0
		draw_line(c + Vector2(cos(a), sin(a)) * 9.0, c + Vector2(cos(a), sin(a)) * 13.0, Color(1, 0.9, 0.4, 0.7), 1.0)
	Toon.circle(self, c, 6.0, Color("ffd54f"))
	Toon.rect(self, Rect2(c.x - 8, c.y + 1, 16, 3), Color("ffb300"))
	draw_rect(Rect2(c.x - 3, c.y - 5, 3, 2), Color(1, 1, 1, 0.8))
