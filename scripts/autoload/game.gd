extends Node
## "Game" é um Autoload (singleton): existe durante o jogo inteiro e
## qualquer script pode acessá-lo escrevendo Game.alguma_coisa.
##
## Responsável por:
##   - criar os controles (teclado, controle e toque)
##   - guardar em qual andar o jogador está
##   - salvar recordes e progresso no aparelho

const SAVE_PATH := "user://progresso.cfg"

var current_floor: int = 0
var unlocked_floor: int = 0
var total_deaths: int = 0
var best_times: Dictionary = {}   # "0" -> 12.5 (segundos)
var best_bolts: Dictionary = {}   # "0" -> 4


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	load_progress()


# ------------------------------------------------------------------
# CONTROLES
# Criados por código para ficar fácil mudar. No celular, o toque na
# tela vira um "clique do mouse" automaticamente, então o botão
# esquerdo do mouse também é "pular".
# ------------------------------------------------------------------
func _setup_input() -> void:
	_add_action("jump", [KEY_SPACE, KEY_W, KEY_UP, KEY_Z, KEY_J], [JOY_BUTTON_A, JOY_BUTTON_B], true)
	_add_action("restart", [KEY_R], [JOY_BUTTON_Y], false)
	_add_action("pause", [KEY_ESCAPE, KEY_P], [JOY_BUTTON_START], false)


func _add_action(action: String, keys: Array, joy_buttons: Array, with_mouse: bool) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action, ev)
	for button in joy_buttons:
		var jev := InputEventJoypadButton.new()
		jev.button_index = button
		InputMap.action_add_event(action, jev)
	if with_mouse:
		var mev := InputEventMouseButton.new()
		mev.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event(action, mev)


# ------------------------------------------------------------------
# ANDARES
# ------------------------------------------------------------------
func floor_count() -> int:
	return LevelData.FLOORS.size()


func floor_name(index: int) -> String:
	var data: Dictionary = LevelData.FLOORS[index]
	return String(data["name"])


func floor_tip(index: int) -> String:
	var data: Dictionary = LevelData.FLOORS[index]
	return String(data.get("tip", ""))


func register_death() -> void:
	total_deaths += 1


## Guarda o resultado de um andar. Retorna true se foi um novo recorde de tempo.
func register_result(index: int, time: float, bolts: int) -> bool:
	var key := str(index)
	var new_record := false
	if not best_times.has(key) or time < float(best_times[key]):
		best_times[key] = time
		new_record = true
	best_bolts[key] = maxi(int(best_bolts.get(key, 0)), bolts)
	unlocked_floor = maxi(unlocked_floor, mini(index + 1, floor_count() - 1))
	save_progress()
	return new_record


func get_best_time(index: int) -> float:
	return float(best_times.get(str(index), -1.0))


# ------------------------------------------------------------------
# SALVAMENTO (arquivo de texto simples na pasta do usuário)
# ------------------------------------------------------------------
func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progresso", "andar_liberado", unlocked_floor)
	cfg.set_value("progresso", "mortes", total_deaths)
	cfg.set_value("recordes", "tempos", best_times)
	cfg.set_value("recordes", "parafusos", best_bolts)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Não foi possível salvar o progresso (erro %d)." % err)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return  # primeira vez jogando: ainda não existe arquivo
	unlocked_floor = int(cfg.get_value("progresso", "andar_liberado", 0))
	total_deaths = int(cfg.get_value("progresso", "mortes", 0))
	var times: Variant = cfg.get_value("recordes", "tempos", {})
	if times is Dictionary:
		best_times = times
	var bolts: Variant = cfg.get_value("recordes", "parafusos", {})
	if bolts is Dictionary:
		best_bolts = bolts
