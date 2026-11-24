extends Node
## Cena principal: carrega os andares, cuida de morte/reinício,
## passagem de andar, pausa e o teste automático (--teste).

var level: Level
var hud: Hud
var _busy: bool = false
var _game_complete: bool = false
var _test_mode: bool = false


func _ready() -> void:
	# A Main nunca pausa (para poder despausar). O andar pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud = Hud.new()
	add_child(hud)
	_test_mode = OS.get_cmdline_user_args().has("--teste")
	if _test_mode:
		_run_smoke_test()
		return
	_load_floor(Game.current_floor)


func _load_floor(index: int) -> void:
	_busy = false
	_game_complete = false
	get_tree().paused = false
	hud.set_paused(false)
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	Game.current_floor = index
	level = Level.new()
	level.name = "Andar%02d" % (index + 1)
	level.floor_index = index
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	level.player_died.connect(_on_player_died)
	level.completed.connect(_on_level_completed)
	level.stats_changed.connect(_on_stats_changed)
	hud.show_floor_intro(index, Game.floor_count(), Game.floor_name(index), Game.floor_tip(index))


func _on_stats_changed(bolts: int, total_bolts: int, time: float) -> void:
	hud.update_stats(bolts, total_bolts, time, Game.total_deaths, Game.get_best_time(Game.current_floor))


func _on_player_died() -> void:
	if _busy or _test_mode:
		return
	_busy = true
	Game.register_death()
	await get_tree().create_timer(0.8).timeout
	if _busy:
		_load_floor.call_deferred(Game.current_floor)


func _on_level_completed(time: float, bolts: int, total_bolts: int) -> void:
	if _busy or _test_mode:
		return
	_busy = true
	var index: int = Game.current_floor
	var new_record: bool = Game.register_result(index, time, bolts)
	var text := "ANDAR %d CONCLUÍDO!\n%.2fs   Parafusos %d/%d" % [index + 1, time, bolts, total_bolts]
	if new_record:
		text += "\nNOVO RECORDE!"
	hud.show_message(text, 1.8)
	await get_tree().create_timer(1.8).timeout
	if not _busy:
		return  # o jogador reiniciou enquanto esperava
	if index + 1 >= Game.floor_count():
		_game_complete = true
		hud.show_message("OBRA ENTREGUE!\n\nVocê chegou ao topo do protótipo.\nMortes: %d\n\nPule para recomeçar." % Game.total_deaths, -1.0)
	else:
		_load_floor.call_deferred(index + 1)


func _unhandled_input(event: InputEvent) -> void:
	if _test_mode:
		return
	if _game_complete:
		if event.is_action_pressed("jump"):
			_load_floor.call_deferred(0)
		return
	if event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("restart"):
		_load_floor.call_deferred(Game.current_floor)
	elif OS.is_debug_build() and event is InputEventKey:
		# Atalho de teste (só no editor): N pula para o próximo andar.
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.physical_keycode == KEY_N:
			_load_floor.call_deferred((Game.current_floor + 1) % Game.floor_count())


func _toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	hud.set_paused(paused)


func _notification(what: int) -> void:
	# No celular: se o jogador sair do app, pausa sozinho.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not _test_mode and not _game_complete:
		if is_instance_valid(level) and not get_tree().paused:
			_toggle_pause()


# ------------------------------------------------------------------
# TESTE AUTOMÁTICO
# Rode com:  godot --headless --path . -- --teste
# Carrega todos os andares e simula alguns segundos apertando "pular".
# Se algum script tiver erro, aparece no terminal (e o GitHub acusa).
# ------------------------------------------------------------------
func _run_smoke_test() -> void:
	print("[TESTE] Iniciando teste de %d andares..." % Game.floor_count())
	for i in Game.floor_count():
		_load_floor(i)
		await get_tree().physics_frame
		var info := "%d linhas, %d parafusos" % [level.rows, level.bolts_total]
		for f in 300:
			if f % 25 == 0:
				Input.action_press("jump")
			elif f % 25 == 4:
				Input.action_release("jump")
			await get_tree().physics_frame
		print("[TESTE] Andar %d (%s) OK: %s" % [i + 1, Game.floor_name(i), info])
	Input.action_release("jump")
	print("[TESTE] Concluído.")
	get_tree().quit(0)
