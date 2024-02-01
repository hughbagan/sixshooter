extends Node3D

@onready var navigation = $Navigation
@onready var player = $Player

func _ready():
	# Mouse invisible and stuck to center of screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	get_tree().call_group("zombies", "set_navigation", navigation)
	get_tree().call_group("spawners", "set_navigation", navigation)
	get_tree().call_group("zombies", "set_player", player)
	get_tree().call_group("spawners", "set_player", player)
	get_tree().call_group("spawners", "set_world", self)
