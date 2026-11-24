class_name Hazard
extends Area2D
## Base para tudo que mata o engenheiro ao encostar.
## Os perigos (vergalhão, martelo, cliente...) herdam deste script.


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2   # detecta o jogador (camada 2)
	monitorable = false
	body_entered.connect(_on_body_entered)
	_setup()


## Cada perigo sobrescreve esta função para criar sua forma de colisão.
func _setup() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()
