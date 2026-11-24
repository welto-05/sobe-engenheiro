class_name ConstructionBackground
extends Node2D
## Fundo do prédio em obra: parede dos fundos, pilares, lajes, janelas
## sem vidro mostrando o céu, tubulação e o número do andar pintado.

var size_px := Vector2(320, 568)
var floor_number: int = 1


func _ready() -> void:
	z_index = -10


func _draw() -> void:
	var w: float = size_px.x
	var h: float = size_px.y
	draw_rect(Rect2(0, 0, w, h), Color("1f2438"))

	var rng := RandomNumberGenerator.new()
	rng.seed = floor_number * 7919

	# Vãos de janela (céu do fim de tarde) entre as lajes
	var window_xs: Array[float] = [40.0, 136.0, 232.0]
	var pillar_xs: Array[float] = [16.0, 112.0, 208.0, 304.0]
	var y := 20.0
	while y < h - 40.0:
		for wx in window_xs:
			var win := Rect2(wx, y, 48, 44)
			draw_rect(win, Color("33416b"))
			draw_rect(Rect2(wx, y + 30, 48, 14), Color("4a3f6b"))
			if rng.randf() < 0.5:
				draw_rect(Rect2(wx + rng.randi_range(4, 40), y + rng.randi_range(4, 20), 1, 1), Color("c5cae9"))
		y += 96.0

	# Lajes (faixas horizontais)
	y = 80.0
	while y < h:
		draw_rect(Rect2(0, y, w, 6), Color("2b3150"))
		draw_rect(Rect2(0, y, w, 1), Color("3a4166"))
		y += 96.0

	# Pilares
	for px in pillar_xs:
		draw_rect(Rect2(px - 6, 0, 12, h), Color("262b44"))
		draw_rect(Rect2(px - 6, 0, 2, h), Color("2f3553"))

	# Tubulação vertical com conexões
	draw_rect(Rect2(292, 0, 4, h), Color("2e4a52"))
	var py := 30.0
	while py < h:
		draw_rect(Rect2(290, py, 8, 3), Color("37595f"))
		py += 64.0

	# Número do andar pintado na parede (perto do chão)
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(24, h - 40), "ANDAR %02d" % floor_number, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1, 1, 1, 0.07))
