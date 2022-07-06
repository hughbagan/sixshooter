extends Spatial

onready var navigation = $Navigation

func _ready():
	# Mouse invisible and stuck to center of screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().call_group("zombies", "set_navigation", navigation)
