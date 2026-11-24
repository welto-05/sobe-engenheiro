class_name Hud
extends CanvasLayer
## Interface na tela: andar atual, parafusos, tempo, mensagens e dicas.
## CanvasLayer fica "grudado" na tela e não se move com a câmera.

var _top: Label
var _center: Label
var _hint: Label
var _msg_timer: float = 0.0
var _hint_timer: float = 0.0
var _paused: bool = false
var _floor_line: String = ""


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS   # funciona mesmo com o jogo pausado

	_top = _make_label(10, HORIZONTAL_ALIGNMENT_LEFT)
	_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_top.offset_left = 6
	_top.offset_right = -6
	_top.offset_top = 4
	_top.offset_bottom = 40
	_top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_center = _make_label(18, HORIZONTAL_ALIGNMENT_CENTER)
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_center.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_center.offset_left = 12
	_center.offset_right = -12

	_hint = _make_label(9, HORIZONTAL_ALIGNMENT_CENTER)
	_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_hint.offset_top = -40
	_hint.offset_bottom = -8
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _make_label(font_size: int, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	add_child(l)
	return l


func _process(delta: float) -> void:
	if _msg_timer > 0.0:
		_msg_timer -= delta
		if _msg_timer <= 0.0 and not _paused:
			_center.text = ""
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0:
			_hint.text = ""


func show_floor_intro(index: int, total: int, floor_title: String, tip: String) -> void:
	_floor_line = "ANDAR %d de %d — %s" % [index + 1, total, floor_title]
	show_message("ANDAR %d\n%s" % [index + 1, floor_title], 1.6)
	var controls := "Toque / Espaço: pular   R: reiniciar   Esc: pausa"
	_hint.text = tip + "\n" + controls if tip != "" else controls
	_hint_timer = 5.0



func update_stats(bolts: int, total_bolts: int, time: float, deaths: int, best: float) -> void:
	var best_txt := "--" if best < 0.0 else "%.1fs" % best
	_top.text = "%s\nParafusos %d/%d   Tempo %.1fs   Recorde %s   Mortes %d" % [
		_floor_line, bolts, total_bolts, time, best_txt, deaths]


## duration < 0 = mensagem fica na tela até ser trocada.
func show_message(text: String, duration: float) -> void:
	_center.text = text
	_msg_timer = duration if duration > 0.0 else 0.0


func clear_message() -> void:
	_center.text = ""
	_msg_timer = 0.0


func set_paused(value: bool) -> void:
	_paused = value
	if value:
		_center.text = "PAUSADO\n\nEsc para continuar\nR para reiniciar o andar"
	else:
		_center.text = ""
