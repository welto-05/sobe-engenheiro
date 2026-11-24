class_name Shapes
extends RefCounted
## Funções de ajuda para criar formas de colisão por código.


static func rect(parent: Node, rect_size: Vector2, offset: Vector2) -> CollisionShape2D:
	var shape := RectangleShape2D.new()
	shape.size = rect_size
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = offset
	parent.add_child(cs)
	return cs


static func circle(parent: Node, radius: float, offset: Vector2) -> CollisionShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = offset
	parent.add_child(cs)
	return cs
