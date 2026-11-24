class_name Spikes
extends Hazard
## Vergalhões expostos (sem a capinha de proteção!). Ocupam a metade de
## baixo de uma célula. A posição é o canto superior esquerdo da célula.


func _setup() -> void:
	z_index = 1
	Shapes.rect(self, Vector2(12, 6), Vector2(8, 13))


func _draw() -> void:
	for i in 3:
		var x0: float = 1.5 + i * 5.0
		Toon.poly(self, PackedVector2Array([Vector2(x0, 16), Vector2(x0 + 2.5, 6), Vector2(x0 + 5, 16)]), Color("cfd8dc"))
		draw_line(Vector2(x0 + 2.5, 8), Vector2(x0 + 2.5, 15), Color("90a4ae"), 1.0)
	Toon.rect(self, Rect2(0, 14, 16, 2), Color("8d6e63"))
