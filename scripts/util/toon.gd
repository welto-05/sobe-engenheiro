class_name Toon
extends RefCounted
## Desenho "cartoon": formas com contorno escuro e olhos grandes.
## Usado pelos inimigos e objetos para todos terem o mesmo estilo.

const OUTLINE := Color("1b1b2f")


static func rect(ci: CanvasItem, r: Rect2, fill: Color) -> void:
	ci.draw_rect(r.grow(1.0), OUTLINE)
	ci.draw_rect(r, fill)


static func circle(ci: CanvasItem, center: Vector2, radius: float, fill: Color) -> void:
	ci.draw_circle(center, radius + 1.0, OUTLINE)
	ci.draw_circle(center, radius, fill)


static func poly(ci: CanvasItem, pts: PackedVector2Array, fill: Color) -> void:
	ci.draw_colored_polygon(pts, fill)
	var closed := PackedVector2Array(pts)
	closed.append(pts[0])
	ci.draw_polyline(closed, OUTLINE, 1.0)


## Olho grande: branco + pupila olhando para "look" (-1..1 em x e y).
static func eye(ci: CanvasItem, center: Vector2, radius: float, look: Vector2) -> void:
	ci.draw_circle(center, radius + 0.8, OUTLINE)
	ci.draw_circle(center, radius, Color.WHITE)
	ci.draw_circle(center + look * radius * 0.45, radius * 0.5, OUTLINE)


## Sobrancelha brava (inclinada para o centro).
static func brow(ci: CanvasItem, center: Vector2, width: float, angry_dir: float) -> void:
	var a := center + Vector2(-width * 0.5, -1.0 * angry_dir)
	var b := center + Vector2(width * 0.5, 1.0 * angry_dir)
	ci.draw_line(a, b, OUTLINE, 1.5)
