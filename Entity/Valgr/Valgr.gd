extends "res://script/Actor.gd"

onready var nav = get_parent().get_node("AStar")
onready var player = get_parent().get_node("Player")

func _ready():
	health = maxHealth
	$AnimationTree.active = true

func _physics_process(delta):
	if health == 0:
		queue_free()
	if current_velocity != Vector3.ZERO:
		$AnimationTree.set("parameters/move_state/current", 1)
	else:
		$AnimationTree.set("parameters/move_state/current", 0)
	if int(current_velocity.x) > 0:
		rotation.y = lerp_angle(rotation.y, 90, 0.5)
	elif int(current_velocity.x) < 0:
		rotation.y = lerp_angle(rotation.y, 180, 0.5)
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
	global_transform.origin.z = lerp(global_transform.origin.z, 0, 0.1)
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

func _on_Area_area_entered(area):
	if !area.damage:
		return
	damage_health(area.damage)
	print('ouch, remaining health: ', health)


func _on_Timer_timeout():
	update_path(nav.find_path(global_transform.origin, player.global_transform.origin))
