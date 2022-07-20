extends KinematicBody

export var health = 100.0
export var maxHealth = 100.0
export var speed = 10
export var acceleration = 0.1

var path := []
var cur_path_idx = 0
var current_target := Vector3.INF
var current_velocity := Vector3.ZERO
var actions_blocked := false

func _ready():
	pass

func damage_health(damage):
	health = clamp(health, 0, maxHealth)
	health -= damage
	if health <= 0:
		handle_death()
	else:
		$AnimationTree.set("parameters/on_hit/active", true)

func handle_death():
	$AnimationTree.set("parameters/is_dead/current", true)
	
