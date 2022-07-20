extends "res://script/Actor.gd"

enum {
	IDLE,
	ALERT
}

var state = IDLE

onready var nav = get_node("/root/Spatial/AStar")
onready var player = get_node("/root/Spatial/Player")
onready var raycasts = $RayCasts
var velocity := Vector3(0,0,0)

func _ready():
	health = maxHealth
	$AnimationTree.active = true

func _physics_process(delta):
	if velocity != Vector3.ZERO:
		$AnimationTree.set("parameters/move_state/current", 1)
	else:
		$AnimationTree.set("parameters/move_state/current", 0)
	if int(velocity.x) > 0:
		rotation.y = lerp_angle(rotation.y, 90, 0.5)
	elif int(velocity.x) < 0:
		rotation.y = lerp_angle(rotation.y, 180, 0.5)
	var lerp_weight = delta * 8.0

	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		velocity = lerp(velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		velocity = lerp(velocity, Vector3.ZERO, lerp_weight)
	global_transform.origin.z = lerp(global_transform.origin.z, 0, 0.1)
	velocity = move_and_slide(velocity)
	
	for ray in raycasts.get_children():
		if(ray.get_collider() == player):
			state = ALERT
			break

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
	if(state == ALERT):
		update_path(nav.find_path(global_transform.origin, player.global_transform.origin))


func _on_IdleRotateTimer_timeout():
	# on time out, stop, turn the fuck around, and move
	pass
