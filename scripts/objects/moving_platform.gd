class_name MovingPlatform
extends AnimatableBody2D
## Plataforma que vai e volta (viga no cabo do guindaste) ou elevador
## de obra (vertical). AnimatableBody2D carrega o jogador junto.
## Posição = canto superior esquerdo da primeira célula.

var width_tiles: int = 4
var vertical: bool = false
var travel: float = 48.0
var period: float = 2.8

var _origin := Vector2.ZERO
var _t: float = 0.0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	z_index = 1
	var cs := Shapes.rect(self, Vector2(width_tiles * 16, 6), Vector2(width_tiles * 8, 3))
	cs.one_way_collision = true
	cs.one_way_collision_margin = 4.0
	_origin = position


func _physics_process(delta: float) -> void:
	_t += delta
	var axis := Vector2.DOWN if vertical else Vector2.RIGHT
	position = _origin + axis * sin(_t * TAU / period) * travel


func _draw() -> void:
	var w: float = width_tiles * 16.0
	if vertical:
		# elevador de obra: gaiola amarela
		Toon.rect(self, Rect2(0.5, 0, w - 1, 5), Color("fdd835"))
		draw_rect(Rect2(1, 0, w - 2, 1), Color(1, 1, 1, 0.6))
		Toon.rect(self, Rect2(1, -16, 2, 16), Color("f9a825"))
		Toon.rect(self, Rect2(w - 3, -16, 2, 16), Color("f9a825"))
		Toon.rect(self, Rect2(1, -17, w - 2, 2), Color("f9a825"))
		var x := 7.0
		while x < w - 4.0:
			draw_line(Vector2(x, -15), Vector2(x, 0), Color(0.1, 0.1, 0.2, 0.35), 1.0)
			x += 5.0
	else:
		# viga suspensa com faixas de atenção e cabo do guindaste
		draw_line(Vector2(w * 0.25, 0), Vector2(w * 0.5, -14), Toon.OUTLINE, 1.0)
		draw_line(Vector2(w * 0.75, 0), Vector2(w * 0.5, -14), Toon.OUTLINE, 1.0)
		draw_line(Vector2(w * 0.5, -14), Vector2(w * 0.5, -60), Toon.OUTLINE, 1.0)
		Toon.circle(self, Vector2(w * 0.5, -14), 2.0, Color("ffca28"))
		Toon.rect(self, Rect2(0.5, 0, w - 1, 6), Color("263238"))
		var i := 0
		while i * 8 + 9 <= int(w):
			draw_colored_polygon(PackedVector2Array([
				Vector2(i * 8 + 1, 6), Vector2(i * 8 + 5, 0), Vector2(i * 8 + 9, 0), Vector2(i * 8 + 5, 6)]), Color("fbc02d"))
			i += 1
		draw_rect(Rect2(0.5, 0, w - 1, 1), Color(1, 1, 1, 0.4))
