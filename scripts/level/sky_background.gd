class_name SkyBackground
extends CanvasLayer
## Céu atrás do prédio (fica fixo na tela, atrás de tudo).
## A cor muda conforme você sobe: azul de dia embaixo -> pôr do sol no topo.
## Nuvens e cidade ao fundo se mexem devagar (parallax) para dar
## sensação de altura.

var level_height: float = 600.0
var _painter: _SkyPainter


func _ready() -> void:
	layer = -1
	_painter = _SkyPainter.new()
	_painter.sky = self
	add_child(_painter)


func _process(_delta: float) -> void:
	_painter.queue_redraw()


class _SkyPainter:
	extends Node2D

	var sky: SkyBackground
	var _t: float = 0.0

	func _process(delta: float) -> void:
		_t += delta

	func _draw() -> void:
		var vp: Vector2 = get_viewport().get_visible_rect().size
		var cam := get_viewport().get_camera_2d()
		var cam_y: float = sky.level_height * 0.5
		if cam != null:
			cam_y = cam.get_screen_center_position().y
		var progress: float = clampf(1.0 - cam_y / maxf(sky.level_height, 1.0), 0.0, 1.0)

		var top := Color("4fc3f7").lerp(Color("7e57c2"), progress)
		var bottom := Color("b3e5fc").lerp(Color("ffab91"), progress)
		draw_polygon(
			PackedVector2Array([Vector2(0, 0), Vector2(vp.x, 0), Vector2(vp.x, vp.y), Vector2(0, vp.y)]),
			PackedColorArray([top, top, bottom, bottom]))

		# sol (desce e fica laranja no topo do prédio)
		var sun := Vector2(vp.x * 0.78, vp.y * (0.18 + progress * 0.25))
		draw_circle(sun, 22.0, Color(1, 0.95, 0.6, 0.35))
		draw_circle(sun, 15.0, Color("fff59d").lerp(Color("ff8a65"), progress))

		# cidade ao longe: some para baixo conforme subimos
		var city_y: float = vp.y - 40.0 + (sky.level_height - cam_y) * 0.08
		var widths: Array[float] = [26.0, 18.0, 34.0, 22.0, 30.0, 16.0, 28.0, 24.0]
		var heights: Array[float] = [60.0, 90.0, 50.0, 110.0, 70.0, 85.0, 55.0, 95.0]
		var x := -6.0
		var i := 0
		var city_col := Color("90a4ae").lerp(Color("6a4f8a"), progress)
		while x < vp.x:
			var w: float = widths[i % widths.size()]
			var h: float = heights[i % heights.size()]
			draw_rect(Rect2(x, city_y - h, w, h + 400.0), city_col)
			var wy: float = city_y - h + 6.0
			while wy < city_y - 4.0:
				draw_rect(Rect2(x + 4, wy, 3, 3), Color(1, 1, 0.8, 0.35))
				wy += 10.0
			x += w + 4.0
			i += 1

		# nuvens cartoon passando
		for k in 5:
			var cx: float = fmod(k * 97.0 + _t * (6.0 + k * 2.0), vp.x + 80.0) - 40.0
			var cy: float = fmod(k * 131.0 + cam_y * 0.15, vp.y + 60.0) - 30.0
			_cloud(Vector2(cx, cy), 0.8 + (k % 3) * 0.25)

	func _cloud(c: Vector2, s: float) -> void:
		var parts: Array[Vector3] = [Vector3(0, 0, 9), Vector3(10, 2, 7), Vector3(-10, 2, 7), Vector3(4, -6, 7)]
		for p in parts:
			draw_circle(c + Vector2(p.x, p.y) * s, (p.z + 1.0) * s, Color(0.3, 0.35, 0.5, 0.25))
		for p in parts:
			draw_circle(c + Vector2(p.x, p.y) * s, p.z * s, Color(1, 1, 1, 0.9))
