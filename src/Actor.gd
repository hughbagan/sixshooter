class_name Actor extends RigidBody3D

const MOVE_SPEED = 5.0
const MOUSE_SENS = 0.3

@onready var raycast = $RayCast3D
@onready var anim_player = $AnimationPlayer
@onready var path_timer = $PathTimer
@onready var hitbox = $Hitbox
@onready var camera = $Camera3D

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
	camera.global_position = global_position


	var move_vec = Vector3()
	var cam_basis = camera.global_transform.basis
	print(cam_basis)
	var modded_basis = cam_basis.rotated(cam_basis.x, PI*0.5)
	if Input.is_action_pressed("move_forwards_2"):
		#print(modded_basis)
		move_vec = -cam_basis.z
	if Input.is_action_pressed("move_backwards_2"):
		#print(modded_basis)
		move_vec = cam_basis.z
	if Input.is_action_pressed("move_left_2"):
		#print(modded_basis)
		move_vec = cam_basis.z.rotated(Vector3(0, 0, 1), PI*0.5)
	if Input.is_action_pressed("move_right_2"):
		#print(modded_basis)
		move_vec = cam_basis.z.rotated(Vector3(0, 0, 1), -PI*0.5)
#	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	apply_central_impulse(move_vec.normalized() / 2)

#	if move_speed > 0.0:
#		direction = direction.normalized()
#		direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
#		move_and_collide(direction * move_speed * delta)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera.rotation_degrees.y -= MOUSE_SENS * event.relative.x

func kill():
	dead = true
	$CollisionShape3D.disabled = true
	anim_player.play("die")
	Globals.score += 100
	emit_signal("died")
