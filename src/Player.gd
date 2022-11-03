extends KinematicBody

const MOVE_SPEED = 7
const MOUSE_SENS = 0.3

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
onready var reload_timer = $ReloadTimer
onready var ammo_label = $CanvasLayer/AmmoLabel
onready var ammo_label_timer = $AmmoLabelTimer
onready var camera = $Camera

var ammo = 6
var reload = 0

func _ready():
	anim_player.play("idle")
	yield(get_tree(), "idle_frame") # wait one frame
	get_tree().call_group("zombies", "set_player", self)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= MOUSE_SENS * event.relative.x
			rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y * MOUSE_SENS, -90, 90)

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
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_collide(move_vec * MOVE_SPEED * delta)

	if Input.is_action_just_pressed("shoot") \
	and reload_timer.is_stopped() \
	and ammo > 0:
		ammo -= 1
		reload = 0
		anim_player.stop()
		anim_player.play("shoot")
		var col = raycast.get_collider()
		if raycast.is_colliding() and col.has_method("kill"):
			col.kill()
		reload_timer.start()
		rotation_degrees.x += 4.0 # gun recoil

	if ammo < 6:
		if Input.is_action_just_pressed("reload_1") and reload==0:
			reload = 1
			anim_player.stop()
			anim_player.play("reload", -1, 0.0)
			print("reload 1")
		if Input.is_action_just_pressed("reload_2") and reload==1:
			reload = 2
			anim_player.seek(0.1)
			print("reload 2")
		if Input.is_action_just_pressed("reload_3") and reload==2:
			ammo += 1
			reload = 0
			anim_player.seek(0.2)
			ammo_label.text = str(ammo)
			ammo_label.show()
			ammo_label_timer.start()
			print("ammo", ammo)

	# "peek" function-- show how much ammo you have
	# Might defeat the purpose of the game though?
	# (To remember how much ammo you have in your head)
	# Maybe make it take up time and screen space,
	# so it's naturally just better to count rounds in your head.
	if Input.is_action_just_pressed("peek_ammo"):
		ammo_label.text = str(ammo)
		ammo_label.show()
		ammo_label_timer.start()

func kill():
	PauseManager.pause()
	show_score()

func show_score():
	ammo_label.text = str(Globals.score)
	ammo_label.set_margins_preset(ammo_label.PRESET_CENTER)
	ammo_label.show()

func _on_ReloadTimer_timeout():
	reload_timer.stop()
	print("ready")

func _on_AmmoLabelTimer_timeout():
	ammo_label.hide()

func _on_Zombie_died():
	if (Globals.score % 1000) == 0:
		show_score()
		ammo_label_timer.start(1.0)
