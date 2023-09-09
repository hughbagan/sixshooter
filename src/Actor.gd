class_name Actor extends RigidBody3D

const MOVE_SPEED = 5.0

@onready var raycast = $RayCast3D
@onready var anim_player = $AnimationPlayer
@onready var path_timer = $PathTimer
@onready var hitbox = $Hitbox

enum {PUNCH_NONE, PUNCH_LEFT, PUNCH_RIGHT}
var punch_mode = PUNCH_NONE

var direction = Vector3()
var move_speed = 0.0

var player = null
var navigation = null
var dead = false
var path = []

signal died

func _ready():
	#add_to_group("zombies")
	#if player:
	#	connect("died", Callable(player, "_on_Zombie_died"))
	#anim_player.play("walk")
	pass

func set_player(p):
	player = p

func set_navigation(n):
	navigation = n

func _physics_process(delta):
	if dead:
		return
	hitbox.global_position = global_position

	var dir = Vector3()
	dir.x = Input.get_action_strength("move_right_2") - Input.get_action_strength("move_left_2")
	dir.z = Input.get_action_strength("move_backwards_2") - Input.get_action_strength("move_forwards_2")
	#add_constant_central_force(dir.normalized() / 2)
	apply_central_impulse(dir.normalized() / 2)

#	if move_speed > 0.0:
#		direction = direction.normalized()
#		direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
#		move_and_collide(direction * move_speed * delta)

func kill():
	dead = true
	$CollisionShape3D.disabled = true
	anim_player.play("die")
	Globals.score += 100
	emit_signal("died")
