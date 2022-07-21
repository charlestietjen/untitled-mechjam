extends KinematicBody

signal on_death

onready var death_explosion_scene = preload("res://Entity/VFX/deathExplosion.tscn")

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
	health = maxHealth
	$AnimationTree.active = true

func damage_health(damage):
	health = clamp(health, 0, maxHealth)
	health -= damage
	if health <= 0:
		handle_death()
	else:
		$AnimationTree.set("parameters/on_hit/active", true)

func handle_death():
	actions_blocked = true
	emit_signal("on_death", self)
	$AnimationTree.set("parameters/is_dead/current", true)

func spawn_explosion():
	pass
#	var death_explosion = death_explosion_scene.instance()
#	get_node("/root/Spatial/").add_child(death_explosion)
#	death_explosion.global_transform.origin = global_transform.origin
