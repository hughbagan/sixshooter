extends CharacterBody3D

const MOVE_SPEED = 7
const MOUSE_SENS = 0.3

@onready var anim_player = $AnimationPlayer
@onready var raycast = $RayCast3D
@onready var reload_timer = $ReloadTimer
@onready var ammo_label = $CanvasLayer/AmmoLabel
@onready var ammo_label_timer = $AmmoLabelTimer
@onready var camera = $Camera3D
@onready var punch_range = $PunchRange
@onready var left_sprite = $CanvasLayer/Control/Left
@onready var right_sprite = $CanvasLayer/Control/Right

enum {PUNCH_NONE, PUNCH_LEFT, PUNCH_RIGHT}
var punch_mode = PUNCH_NONE

var ammo = 6
var reload = 0

func _ready():
	anim_player.play("idle")
	#aawait get_tree().idle_frame # wait one frame
#	get_tree().call_group("zombies", "set_player", self)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= MOUSE_SENS * event.relative.x
			#rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y * MOUSE_SENS, -90, 90)

func _physics_process(delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	velocity = move_vec.normalized().rotated(Vector3(0,1,0), rotation.y) * MOVE_SPEED
	move_and_slide()

	var left = Input.is_action_just_pressed("punch_left")
	var right = Input.is_action_just_pressed("punch_right")

	if (left or right) and reload_timer.is_stopped():
		if left:
			punch_mode = PUNCH_LEFT
			left_sprite.show()
		if right:
			punch_mode = PUNCH_RIGHT
			right_sprite.show()
		reload = 0
		anim_player.stop()
		anim_player.play("shoot")
		var col = raycast.get_collider()
		if raycast.is_colliding() and col.has_method("kill"):
			if col.hitbox:
				if punch_range.overlaps_area(col.hitbox):
					var pos_raised = Vector3(
						raycast.target_position.x,
						raycast.target_position.y+2000,
						raycast.target_position.z
					)
					var to = raycast.to_global(pos_raised)
					var dir = global_transform.origin.direction_to(to)
					col.apply_central_impulse(dir.normalized()*10)
					#print("PUSH", raycast.target_position, pos_raised, to, dir, dir.normalized()*10)
					col.hit = true
		reload_timer.start()
		#rotation_degrees.x += 4.0 # gun recoil
	else:
		punch_mode = PUNCH_NONE

func kill():
	PauseManager.pause()
	show_score()

func show_score():
	ammo_label.text = str(Globals.score)
	ammo_label.set_offsets_preset(ammo_label.PRESET_CENTER)
	ammo_label.show()

func _on_ReloadTimer_timeout():
	reload_timer.stop()
	left_sprite.hide()
	right_sprite.hide()

func _on_AmmoLabelTimer_timeout():
	ammo_label.hide()

#func _on_Zombie_died():
#	if (Globals.score % 1000) == 0:
#		show_score()
#		ammo_label_timer.start(1.0)
