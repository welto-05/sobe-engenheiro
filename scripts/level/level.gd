class_name Level
extends Node2D
## Monta um andar inteiro a partir do mapa de texto em LevelData:
## colisões do cenário, objetos, inimigos, jogador, câmera e céu.
## Também desenha os blocos (concreto, viga, andaime, trilhos, cabos).

signal player_died
signal completed(time: float, bolts: int, total_bolts: int)
signal stats_changed(bolts: int, total_bolts: int, time: float)
signal checkpoint_reached(pos: Vector2)

const TILE := 16
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const GROUND_CHARS := "#=-C"

var floor_index: int = 0
var floor_name: String = ""
var map: PackedStringArray = PackedStringArray()
var cols: int = 0
var rows: int = 0

# Preenchidos pela Main antes de entrar na árvore (para recomeçar do checkpoint)
var has_checkpoint: bool = false
var checkpoint_pos := Vector2.ZERO
var collected_keys: Dictionary = {}
var elapsed: float = 0.0

var player: Player
var camera: LevelCamera
var bolts_total: int = 0
var bolts_collected: int = 0
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

	var sky := SkyBackground.new()
	sky.level_height = rows * TILE
	add_child(sky)
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
		if player.position.y > rows * TILE + 48:
			player.die()
	stats_changed.emit(bolts_collected, bolts_total, elapsed)


# ------------------------------------------------------------------
# LEITURA DO MAPA
# ------------------------------------------------------------------
func _cell(c: int, r: int) -> String:
	if r < 0 or r >= rows or c < 0 or c >= cols:
		return "#"
	var line: String = map[r]
	if c >= line.length():
		return " "
	return line[c]


func _is_solid(ch: String) -> bool:
	return ch == "#" or ch == "="


## Usado pelos inimigos para saber onde andar/virar.
func is_solid_at(world: Vector2) -> bool:
	return _is_solid(_cell(floori(world.x / TILE), floori(world.y / TILE)))


func is_ground_at(world: Vector2) -> bool:
	return GROUND_CHARS.contains(_cell(floori(world.x / TILE), floori(world.y / TILE)))


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
			if ch == "M" or ch == "V" or ch == "S" or ch == "~":
				var start := c
				while c < cols and _cell(c, r) == ch:
					c += 1
				_spawn_run(ch, start, r, c - start)
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
			bolts_total += 1
			var key := "%d,%d" % [c, r]
			if collected_keys.has(key):
				bolts_collected += 1
				return
			var bolt := Bolt.new()
			bolt.position = center
			bolt.collected.connect(_on_bolt_collected.bind(key))
			add_child(bolt)
		"^":
			var spikes := Spikes.new()
			spikes.position = top_left
			add_child(spikes)
		"H":
			var dropper := HammerDropper.new()
			dropper.position = center
			dropper.level = self
			dropper.kill_y = rows * TILE + 32.0
			add_child(dropper)
		"K", "W":
			var walker := Walker.new()
			walker.kind = "worker" if ch == "W" else "client"
			walker.level = self
			walker.position = feet
			add_child(walker)
		"A":
			var pigeon := Pigeon.new()
			pigeon.level = self
			pigeon.position = center
			add_child(pigeon)
		"D":
			var drone := InspectionDrone.new()
			drone.level = self
			drone.position = center
			add_child(drone)
		"X":
			var driver := PileDriver.new()
			driver.position = Vector2(c * TILE + TILE * 0.5, r * TILE)
			driver.drop = _drop_distance(c, r)
			driver.phase = fmod(c * 0.45, driver.wait_time)
			add_child(driver)
		"J":
			var tire := SpringTire.new()
			tire.position = top_left
			add_child(tire)
		"!":
			var cp := Checkpoint.new()
			cp.position = feet
			if has_checkpoint and cp.position.is_equal_approx(checkpoint_pos):
				cp.active = true
			cp.reached.connect(_on_checkpoint)
			add_child(cp)
		"C":
			var crumble := CrumblePlatform.new()
			crumble.position = top_left
			add_child(crumble)


## Quanto o bate-estaca desce até encostar no chão (máx. 7 blocos).
func _drop_distance(c: int, r: int) -> float:
	var n := 0
	while n < 7 and not GROUND_CHARS.contains(_cell(c, r + n + 1)):
		n += 1
	return n * TILE


func _spawn_run(ch: String, start: int, r: int, width: int) -> void:
	match ch:
		"M", "V":
			var p := MovingPlatform.new()
			p.width_tiles = width
			p.vertical = ch == "V"
			p.position = Vector2(start * TILE, r * TILE)
			if p.vertical:
				p.travel = 40.0
				p.period = 3.2
			else:
				p.travel = 48.0
				p.period = 2.8
			add_child(p)
		"S", "~":
			var hz := TrackHazard.new()
			hz.kind = "saw" if ch == "S" else "spark"
			hz.x_min = start * TILE + 8.0
			hz.x_max = (start + width) * TILE - 8.0
			var y: float = (r + 1) * TILE - 8.0 if ch == "S" else r * TILE + 8.0
			hz.position = Vector2((start + width * 0.5) * TILE, y)
			add_child(hz)


func _spawn_player() -> void:
	if not _has_spawn:
		_spawn = Vector2(TILE * 2.5, (rows - 1) * TILE)
	player = PLAYER_SCENE.instantiate() as Player
	player.position = checkpoint_pos if has_checkpoint else _spawn
	player.died.connect(_on_player_died)
	add_child(player)

	camera = LevelCamera.new()
	add_child(camera)
	camera.setup(player, cols * TILE, rows * TILE)


# ------------------------------------------------------------------
# EVENTOS
# ------------------------------------------------------------------
func _on_bolt_collected(key: String) -> void:
	collected_keys[key] = true
	bolts_collected += 1


func _on_checkpoint(pos: Vector2) -> void:
	has_checkpoint = true
	checkpoint_pos = pos
	checkpoint_reached.emit(pos)


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
# DESENHO DOS BLOCOS (estilo cartoon: cores fortes + contorno escuro
# só nas bordas expostas, para os blocos vizinhos parecerem uma peça só)
# ------------------------------------------------------------------
const C_LINE := Color("1b1b2f")


func _draw() -> void:
	for r in rows:
		for c in cols:
			var ch := _cell(c, r)
			var x := float(c * TILE)
			var y := float(r * TILE)
			match ch:
				"#":
					_draw_block(x, y, c, r, Color("c8b8a6"), Color("efe3d3"), Color("8f7f70"))
					_draw_concrete_detail(x, y, c, r)
				"=":
					_draw_block(x, y, c, r, Color("ef5a3c"), Color("ff8a65"), Color("b23a22"))
					draw_circle(Vector2(x + 4, y + 8), 1.5, Color("7f1d0d"))
					draw_circle(Vector2(x + 12, y + 8), 1.5, Color("7f1d0d"))
				"-":
					_draw_scaffold(x, y, c, r)
				"S":
					# trilho da serra
					draw_rect(Rect2(x, y + 7, TILE, 2), C_LINE)
					draw_rect(Rect2(x, y + 7, TILE, 1), Color("78909c"))
				"~":
					# cabo energizado com postinhos nas pontas
					draw_line(Vector2(x, y + 8), Vector2(x + TILE, y + 8), C_LINE, 2.0)
					if _cell(c - 1, r) != "~":
						draw_rect(Rect2(x - 1, y + 4, 3, 8), Color("ffca28"))
					if _cell(c + 1, r) != "~":
						draw_rect(Rect2(x + TILE - 2, y + 4, 3, 8), Color("ffca28"))


func _draw_block(x: float, y: float, c: int, r: int, fill: Color, light: Color, dark: Color) -> void:
	draw_rect(Rect2(x, y, TILE, TILE), fill)
	var up := _is_solid(_cell(c, r - 1))
	var down := _is_solid(_cell(c, r + 1))
	var left := _is_solid(_cell(c - 1, r))
	var right := _is_solid(_cell(c + 1, r))
	if not up:
		draw_rect(Rect2(x, y, TILE, 4), light)
		draw_rect(Rect2(x, y, TILE, 2), C_LINE)
	if not down:
		draw_rect(Rect2(x, y + TILE - 4, TILE, 3), dark)
		draw_rect(Rect2(x, y + TILE - 2, TILE, 2), C_LINE)
	if not left:
		draw_rect(Rect2(x, y, 2, TILE), C_LINE)
	if not right:
		draw_rect(Rect2(x + TILE - 2, y, 2, TILE), C_LINE)


func _draw_concrete_detail(x: float, y: float, c: int, r: int) -> void:
	var n: int = (c * 73 + r * 151) % 9
	if n < 3:
		draw_line(Vector2(x + 4 + n, y + 7), Vector2(x + 8 + n, y + 10), Color("8f7f70"), 1.0)
	elif n < 5:
		draw_circle(Vector2(x + 9, y + 9), 1.0, Color("a89886"))


func _draw_scaffold(x: float, y: float, c: int, r: int) -> void:
	# tubos verticais do andaime
	if c % 3 == 0:
		draw_rect(Rect2(x + 1, y + 4, 3, 12), C_LINE)
		draw_rect(Rect2(x + 2, y + 4, 1, 12), Color("b0bec5"))
	# tábua de madeira
	draw_rect(Rect2(x, y, TILE, 6), Color("f0a04b"))
	draw_rect(Rect2(x, y, TILE, 1), Color("ffd08a"))
	draw_rect(Rect2(x, y + 5, TILE, 1), C_LINE)
	draw_rect(Rect2(x, y - 1, TILE, 1), C_LINE)
	if _cell(c - 1, r) != "-":
		draw_rect(Rect2(x, y - 1, 1, 7), C_LINE)
	if _cell(c + 1, r) != "-":
		draw_rect(Rect2(x + TILE - 1, y - 1, 1, 7), C_LINE)
	draw_rect(Rect2(x + 7, y + 1, 1, 4), Color("c47a2c"))
