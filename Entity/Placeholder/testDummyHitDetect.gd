extends KinematicBody


# Declare member variables here. Examples:
onready var nav = get_parent().get_node("AStar")
onready var player = get_parent().get_node("Player")
export var maxHealth = 100
export var speed = 10
var health
var path := []
var cur_path_idx = 0
var current_target := Vector3.INF
var current_velocity := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if health == 0:
		queue_free()
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
	global_transform.origin.z = 0
	current_velocity = move_and_slide(new_velocity)

func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.z = global_transform.origin.z
		current_target = new_target
	else:
		current_target = Vector3.INF

func update_path(new_path: Array):
	path = new_path
	find_next_point_in_path()

func damage_health(damage):
	health = clamp(health, 0, maxHealth)
	health -= damage
	print('ouch, remaining health: ', health)

func calculate_movement():
#	if global_translate
	pass

func _on_hitbox_area_entered(area):
	damage_health(area.damage)

