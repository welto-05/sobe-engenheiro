class_name Spikes
extends Hazard
## Vergalhões expostos (sem a capinha de proteção!). Ocupam a metade de
## baixo de uma célula. A posição é o canto superior esquerdo da célula.


func _setup() -> void:
	z_index = 1
	# Caixa menor que o desenho: perdoa encostadas de raspão.
	Shapes.rect(self, Vector2(12, 6), Vector2(8, 13))


func _draw() -> void:
	var rod := Color("8d6e63")
	var rod_dark := Color("5d4037")
	var tip := Color("d7ccc8")
	for i in 3:
		var x0: float = 2.0 + i * 5.0
		draw_rect(Rect2(x0, 9, 2, 7), rod)
		draw_rect(Rect2(x0 + 1, 9, 1, 7), rod_dark)
		draw_rect(Rect2(x0, 8, 2, 1), tip)
	draw_rect(Rect2(0, 15, 16, 1), Color("455a64"))
