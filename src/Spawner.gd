extends Sprite3D

onready var batch_timer = $BatchTimer
onready var spawn_timer = $SpawnTimer

var zombie_scene = preload("res://src/Zombie.tscn")
var world = null
var player = null
var navigation = null
export var batch_size = 5
export var batch_timer_time = 30.0
export var spawn_timer_time = 2.0
var batch_count = 0

func _ready():
	add_to_group("spawners")
	batch_timer.start(1)

func set_world(w):
	world = w

func set_player(p):
	player = p

func set_navigation(n):
	navigation = n

func _on_BatchTimer_timeout():
	# Start spawning a batch of enemies
	print("begin batch")
	batch_count = 0
	spawn_timer.start(spawn_timer_time)

func _on_SpawnTimer_timeout():
	var new_enemy = zombie_scene.instance()
	new_enemy.set_translation(Vector3(self.translation.x, new_enemy.translation.y, self.translation.z))
	if navigation:
		new_enemy.set_navigation(navigation)
	if player:
		new_enemy.set_player(player)
	assert(world)
	world.add_child(new_enemy)
	print("Spawned ", new_enemy)
	batch_count += 1
	if batch_count < batch_size:
		spawn_timer.start(spawn_timer_time)
	else:
		batch_timer.start(batch_timer_time) # end of the batch
