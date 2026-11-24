class_name Player
extends CharacterBody2D
## O ENGENHEIRO
## - Corre sozinho e vira quando bate numa parede estando no chão.
## - Pulo, pulo duplo, agarrar/escorregar na parede e pulo de parede.
##
## Todos os números com @export aparecem no Inspetor quando você abre
## scenes/player.tscn. Mude lá para ajustar a sensação do controle.

signal died

enum State { GROUND, AIR, WALL, DEAD, WIN }

@export_group("Corrida")
@export var run_speed: float = 100.0          ## pixels por segundo

@export_group("Pulo")
@export var gravity: float = 1000.0
@export var jump_velocity: float = -330.0     ## negativo = para cima (~3 blocos)
@export var double_jump_velocity: float = -290.0
@export var max_fall_speed: float = 420.0
@export var coyote_time: float = 0.08         ## tempo para ainda pular depois de sair da beirada
@export var jump_buffer_time: float = 0.12    ## aperto "adiantado" antes de tocar o chão também vale
@export var variable_jump: bool = false       ## true = soltar o botão cedo faz pulo mais baixo
@export var jump_cut: float = 0.45

@export_group("Parede")
@export var wall_jump_velocity: float = -330.0
@export var wall_stick_time: float = 0.30     ## tempo parado agarrado antes de escorregar
@export var wall_slide_speed: float = 45.0    ## velocidade máxima escorregando

var state: State = State.AIR
var direction: int = 1          # 1 = direita, -1 = esquerda
var wall_side: int = 0          # lado em que está a parede agarrada
var can_double_jump: bool = true
var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var wall_stick_timer: float = 0.0

# Só visual
var anim_time: float = 0.0
var dj_spin: float = 0.0        # giro do pulo duplo (de TAU até 0)
var dead_spin: float = 0.0
var _flip: int = 1


func _ready() -> void:
	collision_layer = 2   # camada 2 = jogador
	collision_mask = 1    # colide com a camada 1 = cenário
	floor_snap_length = 4.0
	z_index = 5


func is_dead() -> bool:
	return state == State.DEAD


func die() -> void:
	if state == State.DEAD or state == State.WIN:
		return
	state = State.DEAD
	velocity = Vector2(-direction * 50.0, -280.0)
	died.emit()


func celebrate() -> void:
	if state == State.DEAD:
		return
	state = State.WIN
	velocity = Vector2(0.0, minf(velocity.y, 0.0))


# ------------------------------------------------------------------
# LOOP DE FÍSICA (60 vezes por segundo)
# ------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	anim_time += delta
	dj_spin = maxf(dj_spin - delta * TAU / 0.35, 0.0)

	if state == State.DEAD:
		# Morto: sobe, gira e cai atravessando tudo (sem colisão).
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		position += velocity * delta
		dead_spin += delta * 12.0
		queue_redraw()
		return

	if state == State.WIN:
		velocity.x = 0.0
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		if is_on_floor():
			velocity.y = -170.0  # pulinhos de comemoração
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


## Descobre se estamos no chão, na parede ou no ar (usando o resultado
## do move_and_slide do quadro anterior).
func _update_contacts(delta: float) -> void:
	if is_on_floor():
		state = State.GROUND
		coyote_timer = coyote_time
		can_double_jump = true
		wall_side = 0
	elif is_on_wall():
		var side: int = -int(signf(get_wall_normal().x))
		if side != 0:
			if state != State.WALL or side != wall_side:
				# Acabou de agarrar na parede
				wall_side = side
				wall_stick_timer = wall_stick_time
				can_double_jump = true
			state = State.WALL
			direction = wall_side  # continua "empurrando" a parede
	else:
		if state == State.GROUND or state == State.WALL:
			state = State.AIR
			wall_side = 0
		coyote_timer = maxf(coyote_timer - delta, 0.0)


func _try_jump() -> void:
	if jump_buffer <= 0.0:
		return
	if state == State.WALL:
		# Pulo de parede: sai para o lado oposto
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


func _apply_movement(delta: float) -> void:
	if state == State.WALL:
		velocity.x = wall_side * run_speed
		if velocity.y < 0.0:
			velocity.y += gravity * delta           # ainda subindo
		elif wall_stick_timer > 0.0:
			wall_stick_timer -= delta
			velocity.y = 0.0                        # agarrado
		else:
			velocity.y = minf(velocity.y + gravity * delta, wall_slide_speed)  # escorregando
	else:
		velocity.x = direction * run_speed
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _after_move() -> void:
	# Bateu na parede andando no chão: vira para o outro lado.
	if is_on_floor() and is_on_wall():
		var nx: float = get_wall_normal().x
		if nx != 0.0:
			direction = int(signf(nx))


# ------------------------------------------------------------------
# DESENHO (pixel art feita com retângulos, sem precisar de imagens).
# Na Etapa 4 isso será trocado por sprites de verdade.
# ------------------------------------------------------------------
const C_HELMET := Color("f7c623")
const C_HELMET_DARK := Color("c98f12")
const C_HELMET_SHINE := Color("fff2a8")
const C_SKIN := Color("f2b98b")
const C_EYE := Color("2a1b12")
const C_MUSTACHE := Color("6b3d1f")
const C_SHIRT := Color("5b8fd6")
const C_VEST := Color("ff7a1a")
const C_STRIPE := Color("e9f3f5")
const C_PANTS := Color("2f4a80")
const C_PANTS_BACK := Color("223764")
const C_BOOT := Color("5a361b")
const C_DUST := Color(0.85, 0.85, 0.8, 0.8)


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


func _px(x: float, y: float, w: float, h: float, c: Color) -> void:
	var rx: float = x if _flip > 0 else -x - w
	draw_rect(Rect2(rx, y, w, h), c)


func _draw() -> void:
	_flip = _facing()
	var pose := _pose()
	var angle := 0.0
	if pose == "dead":
		angle = dead_spin * _flip
	elif dj_spin > 0.0:
		angle = (TAU - dj_spin) * _flip
	# Gira em torno do centro do corpo (8 px acima dos pés).
	draw_set_transform(Vector2(0, -8), angle, Vector2.ONE)

	var frame: int = int(anim_time * 14.0) % 4
	var bob: float = -1.0 if (pose == "run" and frame % 2 == 1) else 0.0

	# --- pernas e botas (y de 4 a 8) ---
	match pose:
		"run":
			var back_x: float = -3.0 if frame < 2 else 1.0
			var front_x: float = 1.0 if frame < 2 else -3.0
			if frame % 2 == 1:
				_px(-2, 4, 4, 3, C_PANTS)
				_px(-2, 7, 5, 1, C_BOOT)
			else:
				_px(back_x, 4, 3, 3, C_PANTS_BACK)
				_px(back_x - 1, 7, 3, 1, C_BOOT)
				_px(front_x, 4, 3, 3, C_PANTS)
				_px(front_x, 7, 4, 1, C_BOOT)
		"jump", "win":
			_px(-3, 4, 3, 2, C_PANTS_BACK)
			_px(1, 4, 3, 2, C_PANTS)
			_px(-4, 6, 3, 1, C_BOOT)
			_px(1, 6, 4, 1, C_BOOT)
		_:
			_px(-3, 4, 3, 3, C_PANTS_BACK)
			_px(1, 4, 3, 3, C_PANTS)
			_px(-3, 7, 3, 1, C_BOOT)
			_px(1, 7, 4, 1, C_BOOT)

	# --- tronco (colete refletivo) ---
	_px(-4, 0 + bob, 8, 4, C_VEST)
	_px(-4, 2 + bob, 8, 1, C_STRIPE)
	_px(-1, 0 + bob, 2, 1, C_SHIRT)

	# --- braços ---
	match pose:
		"run":
			if frame < 2:
				_px(3, 1 + bob, 2, 2, C_SHIRT)
				_px(5, 2 + bob, 1, 1, C_SKIN)
			else:
				_px(-5, 1 + bob, 2, 2, C_SHIRT)
				_px(-6, 2 + bob, 1, 1, C_SKIN)
		"jump", "win":
			_px(-6, -3, 2, 3, C_SHIRT)
			_px(4, -3, 2, 3, C_SHIRT)
			_px(-6, -4, 2, 1, C_SKIN)
			_px(4, -4, 2, 1, C_SKIN)
		"grab", "slide":
			_px(-7, -2, 3, 2, C_SHIRT)      # braço esticado para a parede
			_px(-8, -3, 1, 2, C_SKIN)
			_px(3, 1, 2, 2, C_SHIRT)
		_:
			_px(-7, 0, 3, 2, C_SHIRT)
			_px(4, 0, 3, 2, C_SHIRT)
			_px(-8, 0, 1, 1, C_SKIN)
			_px(7, 0, 1, 1, C_SKIN)

	# --- cabeça ---
	_px(-4, -4 + bob, 8, 4, C_SKIN)
	if pose == "dead":
		_px(1, -3, 1, 1, C_EYE)
		_px(3, -3, 1, 1, C_EYE)
		_px(2, -2, 1, 1, C_EYE)
	else:
		_px(2, -3 + bob, 1, 2, C_EYE)
	_px(1, -1 + bob, 3, 1, C_MUSTACHE)

	# --- capacete ---
	_px(-4, -8 + bob, 8, 3, C_HELMET)
	_px(-2, -8 + bob, 2, 1, C_HELMET_SHINE)
	_px(-5, -5 + bob, 11, 1, C_HELMET_DARK)

	# --- poeira escorregando na parede ---
	if pose == "slide" and int(anim_time * 20.0) % 2 == 0:
		_px(-7, 6, 1, 1, C_DUST)
		_px(-8, 4, 1, 1, C_DUST)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
