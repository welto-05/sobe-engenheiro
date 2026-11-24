class_name MovingPlatform
extends AnimatableBody2D
## Plataforma que vai e volta (horizontal) ou elevador de obra (vertical).
## AnimatableBody2D carrega o jogador junto automaticamente.
## Posição = canto superior esquerdo da primeira célula.

var width_tiles: int = 3
var vertical: bool = false
var travel: float = 48.0    ## distância máxima para cada lado (pixels)
var period: float = 3.2     ## segundos para ir e voltar

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
		# elevador de obra: piso com grade
		draw_rect(Rect2(0, 0, w, 5), Color("546e7a"))
		draw_rect(Rect2(0, 0, w, 1), Color("90a4ae"))
		draw_rect(Rect2(0, -14, 1, 14), Color("78909c"))
		draw_rect(Rect2(w - 1, -14, 1, 14), Color("78909c"))
		draw_rect(Rect2(0, -14, w, 1), Color("78909c"))
		var x := 4.0
		while x < w - 2.0:
			draw_rect(Rect2(x, -13, 1, 13), Color(0.47, 0.56, 0.61, 0.5))
			x += 4.0
	else:
		# viga suspensa com faixas de atenção
		draw_rect(Rect2(0, 0, w, 5), Color("212121"))
		var i := 0
		while i * 6 < int(w):
			draw_rect(Rect2(i * 6, 0, 3, 5), Color("fbc02d"))
			i += 1
		draw_rect(Rect2(0, 5, w, 1), Color("000000"))
		draw_line(Vector2(w * 0.5, 0), Vector2(w * 0.5, -40), Color(0.75, 0.7, 0.65, 0.6), 1.0)  # cabo do guindaste
