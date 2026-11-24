class_name Player
extends CharacterBody2D
## O ENGENHEIRO
## - Corre sozinho e vira quando bate numa parede estando no chão.
## - Pulo, pulo duplo, agarrar/escorregar na parede e pulo de parede.
## - Pisa na cabeça de alguns inimigos (quica) e é lançado por molas.
##
## Todos os números com @export aparecem no Inspetor quando você abre
## scenes/player.tscn. Mude lá para ajustar a sensação do controle.

signal died

enum State { GROUND, AIR, WALL, DEAD, WIN }

@export_group("Corrida")
@export var run_speed: float = 140.0          ## pixels por segundo

@export_group("Pulo")
@export var gravity: float = 1400.0
@export var jump_velocity: float = -400.0     ## negativo = para cima (~3,5 blocos)
@export var double_jump_velocity: float = -350.0
@export var max_fall_speed: float = 520.0
@export var coyote_time: float = 0.08
@export var jump_buffer_time: float = 0.12
@export var variable_jump: bool = false
@export var jump_cut: float = 0.45
@export var stomp_bounce: float = -380.0      ## quique ao pisar num inimigo

@export_group("Parede")
@export var wall_jump_velocity: float = -400.0
@export var wall_stick_time: float = 0.15
@export var wall_slide_speed: float = 70.0

var state: State = State.AIR
var direction: int = 1
var wall_side: int = 0
var can_double_jump: bool = true
var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var wall_stick_timer: float = 0.0

# Só visual
var anim_time: float = 0.0
var dj_spin: float = 0.0
var dead_spin: float = 0.0
var squash: float = 0.0     # >0 achatado (pousou), <0 esticado (pulou)
var _was_on_floor: bool = false


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 4.0
	z_index = 5


func is_dead() -> bool:
	return state == State.DEAD


func die() -> void:
	if state == State.DEAD or state == State.WIN:
		return
	state = State.DEAD
	velocity = Vector2(-direction * 60.0, -380.0)
	died.emit()


func celebrate() -> void:
	if state == State.DEAD:
		return
	state = State.WIN
	velocity = Vector2(0.0, minf(velocity.y, 0.0))


## Pisou num inimigo ou caiu numa mola: sobe e recupera o pulo duplo.
func bounce(strength: float) -> void:
	if state == State.DEAD or state == State.WIN:
		return
	velocity.y = strength
	state = State.AIR
	can_double_jump = true
	coyote_timer = 0.0
	dj_spin = 0.0
	squash = -0.35


# ------------------------------------------------------------------
# LOOP DE FÍSICA
# ------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	anim_time += delta
	dj_spin = maxf(dj_spin - delta * TAU / 0.3, 0.0)
	squash = move_toward(squash, 0.0, delta * 2.5)

	if state == State.DEAD:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		position += velocity * delta
		dead_spin += delta * 14.0
		queue_redraw()
		return

	if state == State.WIN:
		velocity.x = 0.0
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		if is_on_floor():
			velocity.y = -260.0
			squash = 0.3
		queue_redraw()
		return

	_read_input(delta)
	_update_contacts(delta)
	_try_jump()
	_apply_movement(delta)
	move_and_slide()
	_after_move()
	queue_redraw()


func _read_input(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_time
	else:
		jump_buffer = maxf(jump_buffer - delta, 0.0)
	if variable_jump and Input.is_action_just_released("jump"):
		if state == State.AIR and velocity.y < 0.0:
			velocity.y *= jump_cut


func _update_contacts(delta: float) -> void:
	if is_on_floor():
		if not _was_on_floor:
			squash = 0.35   # pousou: achata
		state = State.GROUND
		coyote_timer = coyote_time
		can_double_jump = true
		wall_side = 0
	elif is_on_wall():
		var side: int = -int(signf(get_wall_normal().x))
		if side != 0:
			if state != State.WALL or side != wall_side:
				wall_side = side
				wall_stick_timer = wall_stick_time
				can_double_jump = true
			state = State.WALL
			direction = wall_side
	else:
		if state == State.GROUND or state == State.WALL:
			state = State.AIR
			wall_side = 0
		coyote_timer = maxf(coyote_timer - delta, 0.0)
	_was_on_floor = is_on_floor()


func _try_jump() -> void:
	if jump_buffer <= 0.0:
		return
	if state == State.WALL:
		direction = -wall_side
		velocity.x = direction * run_speed
		velocity.y = wall_jump_velocity
		state = State.AIR
		wall_side = 0
		_consume_jump()
	elif state == State.GROUND or coyote_timer > 0.0:
		velocity.y = jump_velocity
		state = State.AIR
		_consume_jump()
	elif can_double_jump:
		velocity.y = double_jump_velocity
		can_double_jump = false
		dj_spin = TAU
		_consume_jump()


func _consume_jump() -> void:
	jump_buffer = 0.0
	coyote_timer = 0.0
	squash = -0.3   # estica ao pular


func _apply_movement(delta: float) -> void:
	if state == State.WALL:
		velocity.x = wall_side * run_speed
		if velocity.y < 0.0:
			velocity.y += gravity * delta
		elif wall_stick_timer > 0.0:
			wall_stick_timer -= delta
			velocity.y = 0.0
		else:
			velocity.y = minf(velocity.y + gravity * delta, wall_slide_speed)
	else:
		velocity.x = direction * run_speed
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _after_move() -> void:
	if is_on_floor() and is_on_wall():
		var nx: float = get_wall_normal().x
		if nx != 0.0:
			direction = int(signf(nx))
			squash = 0.2


# ------------------------------------------------------------------
# DESENHO CARICATO (cabeção, olhos grandes, bigode, contorno escuro,
# achata e estica). Coordenadas olhando para a DIREITA, pés em y = 0.
# ------------------------------------------------------------------
const OUTLINE := Color("1b1b2f")
const C_HELMET := Color("ffd23f")
const C_HELMET_DARK := Color("e09a1a")
const C_SKIN := Color("ffc29a")
const C_NOSE := Color("f28c6b")
const C_MUSTACHE := Color("5a3418")
const C_VEST := Color("ff6b1a")
const C_STRIPE := Color("f4fbff")
const C_SHIRT := Color("4f8fe8")
const C_PANTS := Color("2c4a8f")
const C_BOOT := Color("6b3b1a")

var _parts: Array = []   # lista de [tipo, dados, cor] montada a cada desenho


func _facing() -> int:
	if state == State.WALL:
		return -wall_side
	return direction


func _pose() -> String:
	match state:
		State.DEAD:
			return "dead"
		State.WIN:
			return "win"
		State.WALL:
			return "slide" if velocity.y > 0.0 else "grab"
		State.GROUND:
			return "run"
	return "jump" if velocity.y < 0.0 else "fall"


func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	_parts.append([0, Rect2(x, y, w, h), c])


func _c(x: float, y: float, radius: float, c: Color) -> void:
	_parts.append([1, Vector3(x, y, radius), c])


func _draw() -> void:
	var pose := _pose()
	var flip: float = float(_facing())
	var angle := 0.0
	var pivot := Vector2.ZERO
	var oy := 0.0
	if pose == "dead":
		angle = dead_spin
	elif dj_spin > 0.0:
		angle = TAU - dj_spin
	if angle != 0.0:
		pivot = Vector2(0, -11)   # gira em volta do centro do corpo
		oy = 11.0
	var sx: float = 1.0 + squash * 0.6
	var sy: float = 1.0 - squash * 0.6
	draw_set_transform(pivot, angle * flip, Vector2(sx * flip, sy))

	_parts.clear()
	var frame: int = int(anim_time * 16.0) % 4
	var bob: float = -1.0 if (pose == "run" and frame % 2 == 1) else 0.0

	# ---- pernas e botas ----
	match pose:
		"run":
			var a: float = 2.0 if frame < 2 else -3.0
			var b: float = -3.0 if frame < 2 else 2.0
			_r(b, -4 + oy, 2, 2, C_PANTS)
			_r(b - 1, -2 + oy, 4, 2, C_BOOT)
			_r(a, -4 + oy, 2, 2, C_PANTS)
			_r(a, -2 + oy, 4, 2, C_BOOT)
		"jump", "win":
			_r(-3, -5 + oy, 2, 2, C_PANTS)
			_r(1, -5 + oy, 2, 2, C_PANTS)
			_r(-4, -3 + oy, 3, 2, C_BOOT)
			_r(1, -3 + oy, 4, 2, C_BOOT)
		_:
			_r(-3, -4 + oy, 2, 2, C_PANTS)
			_r(1, -4 + oy, 2, 2, C_PANTS)
			_r(-4, -2 + oy, 3, 2, C_BOOT)
			_r(1, -2 + oy, 4, 2, C_BOOT)

	# ---- corpo (colete refletivo) ----
	_r(-4, -9 + oy + bob, 8, 5, C_VEST)

	# ---- braços ----
	match pose:
		"run":
			var arm: float = 3.0 if frame < 2 else -6.0
			_r(arm, -8 + oy + bob, 3, 2, C_SHIRT)
			_c(arm + 1.5 + (1.5 if arm > 0.0 else -1.5), -7 + oy + bob, 1.3, C_SKIN)
		"jump", "win":
			_r(-7, -12 + oy, 2, 4, C_SHIRT)
			_r(5, -12 + oy, 2, 4, C_SHIRT)
			_c(-6, -13 + oy, 1.4, C_SKIN)
			_c(6, -13 + oy, 1.4, C_SKIN)
		"grab", "slide":
			_r(-8, -11 + oy, 4, 2, C_SHIRT)
			_c(-8.5, -10 + oy, 1.4, C_SKIN)
		_:
			_r(-8, -9 + oy, 4, 2, C_SHIRT)
			_r(4, -9 + oy, 4, 2, C_SHIRT)
			_c(-8.5, -8 + oy, 1.4, C_SKIN)
			_c(8.5, -8 + oy, 1.4, C_SKIN)

	# ---- cabeção ----
	_c(1, -14 + oy + bob, 6.0, C_SKIN)
	_c(7.5, -12.5 + oy + bob, 2.0, C_NOSE)
	# ---- capacete ----
	_c(1, -17 + oy + bob, 6.5, C_HELMET)
	_r(-6, -17 + oy + bob, 16, 2, C_HELMET_DARK)

	# Passo 1: contorno (tudo desenhado 1 px maior em cor escura)
	for p in _parts:
		if p[0] == 0:
			var rc: Rect2 = p[1]
			draw_rect(rc.grow(1.0), OUTLINE)
		else:
			var cv: Vector3 = p[1]
			draw_circle(Vector2(cv.x, cv.y), cv.z + 1.0, OUTLINE)
	# Passo 2: cores
	for p in _parts:
		if p[0] == 0:
			draw_rect(p[1], p[2])
		else:
			var cv2: Vector3 = p[1]
			draw_circle(Vector2(cv2.x, cv2.y), cv2.z, p[2])

	# ---- detalhes sem contorno ----
	var hy: float = oy + bob
	draw_rect(Rect2(-4, -7 + oy + bob, 8, 1), C_STRIPE)          # faixa refletiva
	draw_rect(Rect2(-1, -21 + hy, 3, 1), Color(1, 1, 1, 0.8))      # brilho do capacete
	draw_rect(Rect2(0, -20 + hy, 2, 1), Color(1, 1, 1, 0.5))
	# olhos grandes
	if pose == "dead":
		for e in [2.5, 5.5]:
			draw_line(Vector2(e - 1.2, -15.2 + hy), Vector2(e + 1.2, -12.8 + hy), OUTLINE, 1.0)
			draw_line(Vector2(e - 1.2, -12.8 + hy), Vector2(e + 1.2, -15.2 + hy), OUTLINE, 1.0)
	else:
		var look_y: float = -0.6 if (pose == "jump" or pose == "win") else (0.6 if pose == "fall" else 0.0)
		for e in [2.5, 5.3]:
			draw_circle(Vector2(e, -14 + hy), 1.9, Color.WHITE)
			draw_circle(Vector2(e + 0.7, -14 + hy + look_y), 1.0, OUTLINE)
	# bigodão
	draw_rect(Rect2(3, -11 + hy, 6, 2), C_MUSTACHE)
	draw_rect(Rect2(2, -10 + hy, 2, 1), C_MUSTACHE)
	draw_rect(Rect2(8, -10 + hy, 2, 1), C_MUSTACHE)
	# boca de espanto ao morrer
	if pose == "dead":
		draw_circle(Vector2(5.5, -8.5 + hy), 1.2, OUTLINE)

	# poeirinha escorregando na parede
	if pose == "slide" and int(anim_time * 20.0) % 2 == 0:
		draw_circle(Vector2(-9, -2 + oy), 1.2, Color(1, 1, 1, 0.7))
		draw_circle(Vector2(-10, -6 + oy), 0.9, Color(1, 1, 1, 0.5))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
