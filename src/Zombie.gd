class_name Zombie extends CharacterBody3D

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
	add_to_group("zombies")
	if player:
		connect("died", Callable(player, "_on_Zombie_died"))
	anim_player.play("walk")

func set_player(p):
	player = p

func set_navigation(n):
	navigation = n

func _physics_process(delta):
	if dead:
		return
#	if player == null:
#		return

	if move_speed > 0.0:
		direction = direction.normalized()
		direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
		move_and_collide(direction * move_speed * delta)

	# Create the path to the player
#	if path_timer.is_stopped():
#		path_timer.start()

	# Walk the path
#	var direction = Vector3()
#	if path.size() > 0:
#		# Go to the nearest/next point on the path
#		var destination = path[0]
#		direction = destination - position
#		var step_size = delta * MOVE_SPEED
#		# Clamp step size if we're near the node
#		if step_size > direction.length():
#			step_size = direction.length()
#			path.remove(0) # we just reached this node
#		# Move to the path node
#		var col = move_and_collide(direction.normalized() * step_size)
#		if col != null:
#			if col.get_collider().name == "Player":
#				col.get_collider().kill()
#		# Look in the direction we're travelling
#		direction.y = 0 # only look left/right, not up/down
#		if direction:
#			var look_at_point = position + direction.normalized()
#			look_at(look_at_point, Vector3.UP)

func kill():
	dead = true
	$CollisionShape3D.disabled = true
	anim_player.play("die")
	Globals.score += 100
	emit_signal("died")

func _on_PathTimer_timeout():
	# Calculate the path to the player
	# Still handles corners slightly weird.
	return
#	path = []
#	var p = navigation.get_simple_path(position, player.position, true)
#	# Fix path y translations to keep us above the floor
#	for point in p:
#		path.append(Vector3(point.x, position.y, point.z))
