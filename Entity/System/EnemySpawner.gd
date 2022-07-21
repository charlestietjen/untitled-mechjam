extends Node

export (PackedScene) var enemy_scene
export var wave_size = 1
export var group_size = 1
export var spawn_interval = 2

var enemies_active = []

func _ready():
	$SpawnTimer.wait_time = spawn_interval
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SpawnTimer_timeout():
#	print("Spawning Enemy")
	for wave_entity in range(group_size):
		
		var enemy = enemy_scene.instance()
	
		var enemy_spawn_location = get_node("SpawnPath/SpawnLocation")
	
		enemy_spawn_location.unit_offset = randf()
#		enemy.initialize(enemy_spawn_location.translation, Vector3.RIGHT)
	
		add_child(enemy)
		enemies_active.append(enemy)
	
	if enemies_active.size() >= wave_size * group_size:
		$SpawnTimer.stop()
#	print("Enemies Spawned", enemies_active)
	
