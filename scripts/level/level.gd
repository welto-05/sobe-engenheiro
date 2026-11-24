class_name Level
extends Node2D
## Monta um andar inteiro a partir do mapa de texto em LevelData:
## colisões do cenário, objetos, perigos, jogador e câmera.
## Também desenha os blocos (concreto, viga, andaime).

signal player_died
signal completed(time: float, bolts: int, total_bolts: int)
signal stats_changed(bolts: int, total_bolts: int, time: float)

const TILE := 16
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

var floor_index: int = 0
var floor_name: String = ""
var map: PackedStringArray = PackedStringArray()
var cols: int = 0
var rows: int = 0

var player: Player
var camera: LevelCamera
var bolts_total: int = 0
var bolts_collected: int = 0
var elapsed: float = 0.0
var running: bool = true

var _spawn := Vector2.ZERO
var _has_spawn: bool = false


func _ready() -> void:
	var data: Dictionary = LevelData.FLOORS[floor_index]
	floor_name = String(data["name"])
	map = PackedStringArray(data["map"])
	rows = map.size()
	cols = map[0].length()
	_validate_map()

	var bg := ConstructionBackground.new()
	bg.size_px = Vector2(cols * TILE, rows * TILE)
	bg.floor_number = floor_index + 1
	add_child(bg)

	_build_solids()
	_build_one_way()
	_spawn_objects()
	_spawn_player()
	queue_redraw()


func _process(delta: float) -> void:
	if running:
		elapsed += delta
		# Segurança: se por algum motivo cair para fora do mapa, morre.
		if player.position.y > rows * TILE + 48:
			player.die()
	stats_changed.emit(bolts_collected, bolts_total, elapsed)


# ------------------------------------------------------------------
# LEITURA DO MAPA
# ------------------------------------------------------------------
func _cell(c: int, r: int) -> String:
	if r < 0 or r >= rows or c < 0 or c >= cols:
		return "#"   # fora do mapa conta como parede
	var line: String = map[r]
	if c >= line.length():
		return " "
	return line[c]


func _is_solid(ch: String) -> bool:
	return ch == "#" or ch == "="


func _validate_map() -> void:
	var spawns := 0
	var exits := 0
	for r in rows:
		var line: String = map[r]
		if line.length() != cols:
			push_error("Andar %d, linha %d: tem %d colunas (esperado %d)." % [floor_index + 1, r, line.length(), cols])
		spawns += line.count("P")
		exits += line.count("E")
	if spawns != 1:
		push_error("Andar %d: precisa ter exatamente 1 'P' (tem %d)." % [floor_index + 1, spawns])
	if exits < 1:
		push_error("Andar %d: precisa ter pelo menos 1 'E'." % [floor_index + 1])


# ------------------------------------------------------------------
# COLISÕES DO CENÁRIO
# Junta blocos vizinhos em retângulos grandes (menos formas = mais
# desempenho no celular e paredes lisas para escorregar).
# ------------------------------------------------------------------
func _build_solids() -> void:
	var body := StaticBody2D.new()
	body.name = "Solidos"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	var used := {}
	for r in rows:
		for c in cols:
			if used.has(Vector2i(c, r)) or not _is_solid(_cell(c, r)):
				continue
			var w := 1
			while c + w < cols and _is_solid(_cell(c + w, r)) and not used.has(Vector2i(c + w, r)):
				w += 1
			var h := 1
			var can_grow := true
			while can_grow and r + h < rows:
				for i in w:
					if not _is_solid(_cell(c + i, r + h)) or used.has(Vector2i(c + i, r + h)):
						can_grow = false
						break
				if can_grow:
					h += 1
			for yy in h:
				for xx in w:
					used[Vector2i(c + xx, r + yy)] = true
			Shapes.rect(body, Vector2(w * TILE, h * TILE), Vector2((c + w * 0.5) * TILE, (r + h * 0.5) * TILE))


func _build_one_way() -> void:
	var body := StaticBody2D.new()
	body.name = "Andaimes"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	for r in rows:
		var c := 0
		while c < cols:
			if _cell(c, r) == "-":
				var start := c
				while c < cols and _cell(c, r) == "-":
					c += 1
				var w := c - start
				var cs := Shapes.rect(body, Vector2(w * TILE, 6), Vector2((start + w * 0.5) * TILE, r * TILE + 3))
				cs.one_way_collision = true
				cs.one_way_collision_margin = 4.0
			else:
				c += 1


# ------------------------------------------------------------------
# OBJETOS
# ------------------------------------------------------------------
func _spawn_objects() -> void:
	for r in rows:
		var c := 0
		while c < cols:
			var ch := _cell(c, r)
			if ch == "M" or ch == "V":
				var start := c
				while c < cols and _cell(c, r) == ch:
					c += 1
				_spawn_mover(start, r, c - start, ch == "V")
				continue
			_spawn_single(ch, c, r)
			c += 1


func _spawn_single(ch: String, c: int, r: int) -> void:
	var top_left := Vector2(c * TILE, r * TILE)
	var feet := Vector2(c * TILE + TILE * 0.5, (r + 1) * TILE)
	var center := top_left + Vector2(TILE * 0.5, TILE * 0.5)
	match ch:
		"P":
			_spawn = feet
			_has_spawn = true
		"E":
			var door := ExitDoor.new()
			door.position = feet
			door.reached.connect(_on_exit_reached)
			add_child(door)
		"o":
			var bolt := Bolt.new()
			bolt.position = center
			bolt.collected.connect(_on_bolt_collected)
			add_child(bolt)
			bolts_total += 1
		"^":
			var spikes := Spikes.new()
			spikes.position = top_left
			add_child(spikes)
		"H":
			var dropper := HammerDropper.new()
			dropper.position = center
			dropper.phase = fmod(c * 0.7 + r * 0.3, dropper.interval)
			dropper.kill_y = rows * TILE + 32.0
			add_child(dropper)
		"K":
			var client := Client.new()
			client.position = feet
			add_child(client)
		"C":
			var crumble := CrumblePlatform.new()
			crumble.position = top_left
			add_child(crumble)


func _spawn_mover(start: int, r: int, width: int, is_vertical: bool) -> void:
	var p := MovingPlatform.new()
	p.width_tiles = width
	p.vertical = is_vertical
	p.position = Vector2(start * TILE, r * TILE)
	if is_vertical:
		p.travel = 40.0
		p.period = 3.6
	else:
		p.travel = 48.0
		p.period = 3.2
	add_child(p)


func _spawn_player() -> void:
	if not _has_spawn:
		_spawn = Vector2(TILE * 2.5, (rows - 1) * TILE)
	player = PLAYER_SCENE.instantiate() as Player
	player.position = _spawn
	player.died.connect(_on_player_died)
	add_child(player)

	camera = LevelCamera.new()
	add_child(camera)
	camera.setup(player, cols * TILE, rows * TILE)


# ------------------------------------------------------------------
# EVENTOS
# ------------------------------------------------------------------
func _on_bolt_collected() -> void:
	bolts_collected += 1


func _on_player_died() -> void:
	if not running:
		return
	running = false
	camera.target = null
	player_died.emit()


func _on_exit_reached() -> void:
	if not running:
		return
	running = false
	player.celebrate()
	completed.emit(elapsed, bolts_collected, bolts_total)


# ------------------------------------------------------------------
# DESENHO DOS BLOCOS
# ------------------------------------------------------------------
func _draw() -> void:
	for r in rows:
		for c in cols:
			var ch := _cell(c, r)
			var x := float(c * TILE)
			var y := float(r * TILE)
			match ch:
				"#":
					_draw_concrete(x, y, c, r)
				"=":
					_draw_beam(x, y)
				"-":
					_draw_scaffold(x, y, c)


func _draw_concrete(x: float, y: float, c: int, r: int) -> void:
	draw_rect(Rect2(x, y, TILE, TILE), Color("858b96"))
	if not _is_solid(_cell(c, r - 1)):
		draw_rect(Rect2(x, y, TILE, 2), Color("b4bac4"))
	if not _is_solid(_cell(c, r + 1)):
		draw_rect(Rect2(x, y + TILE - 2, TILE, 2), Color("5c616b"))
	var n: int = (c * 73 + r * 151) % 7
	draw_rect(Rect2(x + 3 + n, y + 5 + (n % 3) * 2, 1, 1), Color("6d727c"))
	draw_rect(Rect2(x + 11 - n % 4, y + 11, 1, 1), Color("9ba1ab"))
	draw_rect(Rect2(x, y, 1, TILE), Color(0, 0, 0, 0.06))


func _draw_beam(x: float, y: float) -> void:
	draw_rect(Rect2(x, y, TILE, TILE), Color("b8402c"))
	draw_rect(Rect2(x, y, TILE, 3), Color("d9614a"))
	draw_rect(Rect2(x, y + TILE - 3, TILE, 3), Color("8a2d20"))
	draw_rect(Rect2(x + 3, y + 7, 2, 2), Color("f0c0a0"))
	draw_rect(Rect2(x + 11, y + 7, 2, 2), Color("f0c0a0"))


func _draw_scaffold(x: float, y: float, c: int) -> void:
	draw_rect(Rect2(x, y, TILE, 4), Color("c48a3a"))
	draw_rect(Rect2(x, y + 3, TILE, 1), Color("8c5d22"))
	draw_rect(Rect2(x + 7, y, 1, 3), Color("a87430"))
	draw_rect(Rect2(x, y + 6, TILE, 2), Color("7f8a96"))
	if c % 3 == 0:
		draw_rect(Rect2(x + 1, y + 4, 2, 12), Color("6c7682"))
