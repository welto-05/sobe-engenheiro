class_name ConstructionBackground
extends Node2D
## Esqueleto do prédio em obra (no mundo, atrás dos blocos):
## pilares, vigas, contraventamentos em X, tela de proteção e o
## número do andar pintado. Deixa o céu aparecer entre as estruturas.

var size_px := Vector2(320, 568)
var floor_number: int = 1


func _ready() -> void:
	z_index = -10


func _draw() -> void:
	var w: float = size_px.x
	var h: float = size_px.y
	var frame := Color(0.25, 0.3, 0.45, 0.55)
	var frame_light := Color(0.55, 0.62, 0.78, 0.45)

	# pilares
	var pillar_xs: Array[float] = [16.0, 120.0, 200.0, 304.0]
	for px in pillar_xs:
		draw_rect(Rect2(px - 5, 0, 10, h), frame)
		draw_rect(Rect2(px - 5, 0, 2, h), frame_light)

	# vigas a cada "pavimento" + X de contraventamento
	var y := 64.0
	var k := 0
	while y < h:
		draw_rect(Rect2(0, y, w, 6), frame)
		draw_rect(Rect2(0, y, w, 1), frame_light)
		if k % 2 == 0:
			draw_line(Vector2(120, y), Vector2(200, y + 128), Color(0.25, 0.3, 0.45, 0.35), 2.0)
			draw_line(Vector2(200, y), Vector2(120, y + 128), Color(0.25, 0.3, 0.45, 0.35), 2.0)
		y += 128.0
		k += 1

	# tela de proteção verde em algumas faixas
	y = 140.0
	while y < h:
		draw_rect(Rect2(16, y, 104, 50), Color(0.2, 0.6, 0.35, 0.18))
		var gx := 18.0
		while gx < 120.0:
			draw_line(Vector2(gx, y), Vector2(gx, y + 50), Color(0.2, 0.6, 0.35, 0.18), 1.0)
			gx += 6.0
		y += 384.0

	# número do andar pintado
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(24, h - 36), "ANDAR %02d" % floor_number, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1, 0.18))
