class_name Actor extends RigidBody3D

const MOVE_SPEED = 5.0
const MOUSE_SENS = 0.3

@onready var raycast = $RayCast3D
@onready var anim_player = $AnimationPlayer
@onready var path_timer = $PathTimer
@onready var hitbox = $Hitbox
@onready var camera = $Camera3D
@onready var nav = $NavigationAgent3D
@onready var sprite = $Sprite3D
@onready var gridmap := get_node("/root/World/NavigationRegion3D/GridMap")

enum {PUNCH_NONE, PUNCH_LEFT, PUNCH_RIGHT}
var punch_mode = PUNCH_NONE

var direction = Vector3()
var move_speed = 0.0

var player = null
var navigation = null
var dead = false
var hit = false
var path = []

signal died

func _ready():
	add_to_group("zombies")
	if player:
		connect("died", Callable(player, "_on_Zombie_died"))
	anim_player.play("walk")
	nav.velocity_computed.connect(Callable(_on_velocity_computed))

func set_player(p):
	player = p

func set_navigation(n):
	navigation = n

func _physics_process(delta):
	if dead:
		return
	hitbox.global_position = global_position
	camera.global_position = global_position

	#print(angular_velocity)
	if hit:
		sprite.billboard = BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED
		anim_player.pause()
		sprite.rotation = rotation
		# TODO: Figuring out when we're done flying needs some massaging
#		if (abs(angular_velocity.x) <= 0.03 and abs(angular_velocity.y) <= 0.03) \
#		or (abs(angular_velocity.x) <= 0.03 and abs(angular_velocity.z) <= 0.03) \
#		or (abs(angular_velocity.y) <= 0.03 and abs(angular_velocity.z) <= 0.03):
#			hit = false
	else:
		sprite.billboard = BaseMaterial3D.BillboardMode.BILLBOARD_FIXED_Y
		anim_player.play()
		set_movement_target(player.global_position)
		if nav.is_navigation_finished():
			return
		var next_path_position:Vector3 = nav.get_next_path_position()
		var current_agent_position:Vector3 = global_position
		var new_velocity:Vector3 = (next_path_position - current_agent_position).normalized() * MOVE_SPEED
		if nav.avoidance_enabled:
			nav.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

	var move_vec = Vector3()
	var cam_basis = camera.global_transform.basis
	if Input.is_action_pressed("move_forwards_2"):
		move_vec = -cam_basis.z
		apply_central_impulse(move_vec.normalized() / 2)
	if Input.is_action_pressed("move_backwards_2"):
		move_vec = cam_basis.z
		apply_central_impulse(move_vec.normalized() / 2)
	if Input.is_action_pressed("move_left_2"):
		move_vec = cam_basis.z.rotated(Vector3(0, 0, 1), PI*0.5)
		apply_central_impulse(move_vec.normalized() / 2)
	if Input.is_action_pressed("move_right_2"):
		move_vec = cam_basis.z.rotated(Vector3(0, 0, 1), -PI*0.5)
		apply_central_impulse(move_vec.normalized() / 2)
#	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)


#	if move_speed > 0.0:
#		direction = direction.normalized()
#		direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
#		move_and_collide(direction * move_speed * delta)

#func _input(event):
#	if event is InputEventMouseMotion:
#		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#			camera.rotation_degrees.y -= MOUSE_SENS * event.relative.x

func set_movement_target(movement_target:Vector3):
	nav.set_target_position(movement_target)

func _on_velocity_computed(safe_velocity:Vector3):
	linear_velocity = safe_velocity

func kill():
	dead = true
	$CollisionShape3D.disabled = true
	anim_player.play("die")
	Globals.score += 100
	emit_signal("died")
