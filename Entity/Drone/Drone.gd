extends "res://script/Actor.gd"

enum {
	IDLE,
	ALERT,
	COOLDOWN
}

export var damage = 5
export var damage_type := "ranged"

onready var bullet_scene := preload("res://Entity/Weapon/DroneBullet.tscn")
#onready var nav = get_node("/root/Spatial/AStar")
onready var nav : Navigation = get_node("/root/Spatial/Navigation")
onready var player = get_node("/root/Spatial/Player")
onready var raycasts = $RayCasts
onready var rng = RandomNumberGenerator.new()
var waypoints : Array
var velocity := Vector3(0,0,0)
var target = null
var state = IDLE
var distance_to_target := 0

func _ready():
	waypoints = get_tree().get_nodes_in_group("waypoints")

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
	if target:
		distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
		look_at(target.global_transform.origin, Vector3.UP)
		rotate_object_local(Vector3.DOWN, PI)
		rotation.x = clamp(rotation.x, -0.8, 0.8)
	elif current_target != Vector3.INF && state == IDLE:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		velocity = lerp(velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		rotation.x = lerp_angle(rotation.x, 0, 0.1)
	if current_target != Vector3.INF && distance_to_target > 40:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		velocity = lerp(velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		velocity = lerp(velocity, Vector3.ZERO, lerp_weight)
	global_transform.origin.z = lerp(global_transform.origin.z, 0, 0.1)
	velocity = move_and_slide(velocity)
	
	if state == IDLE:
		for ray in raycasts.get_children():
			if(ray.get_collider() == player):
				state = ALERT
				target = player
				$pathfindTimer.wait_time = 1.0
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

func set_hurtbox_enabled(hurtbox_state):
	$Armature/Skeleton/leftHandAttach/hurtboxContainer/hurtBoxArea/hurtBoxCollider.disabled = !hurtbox_state

func attack():
	$AnimationTree.set("parameters/is_attacking/current", true)
	var bullet = bullet_scene.instance()
	$root/Skeleton/BoneAttachment/bulletSpawn.add_child(bullet)
	bullet.look_at(target.global_transform.origin, Vector3.FORWARD)
	bullet.velocity = Vector3(0,0,-30)
	actions_blocked = true

func _on_Area_area_entered(area):
	if area.damage_type == "range":
		$bulletHitSfx.play()
		damage_health(area.damage)
#		print('ouch, remaining health: ', health)
		area.get_parent().queue_free()
	elif area.damage_type == "melee":
		$meleeHitSfx.play()
		damage_health(area.damage)
#		print('ouch, remaining health: ', health)

func _on_IdleRotateTimer_timeout():
	# on time out, stop, turn the fuck around, and move
	pass

# start repeating timer on first change to alert state
# on timer:
# make attack roll
# if alert state && within melee range & attack roll succeeds:
# set animation state to attack and move towards target
# set state to cooldown & start cooldown timer
# on cooldown timer:
# set state to alert


func _on_pathfindTimer_timeout():
	if(state == ALERT):
		update_path(nav.get_simple_path(global_transform.origin, player.global_transform.origin))
	elif (state == IDLE):
		var new_waypoint = randi() % 4
		rng.randomize()
		var new_wait_time = rng.randf_range(3.0, 10.0)
		$pathfindTimer.wait_time = new_wait_time
		update_path(nav.get_simple_path(global_transform.origin, waypoints[new_waypoint].global_transform.origin))


func _on_attackTimer_timeout():
	var attack_roll = randi() & 100 + 1
	if target != null && !actions_blocked:
#		print(distance_to_target)
		if (state == ALERT) && attack_roll > 50 && distance_to_target <= 40:
			attack()
			$coolDownTimer.start()
			state = COOLDOWN

func _on_coolDownTimer_timeout():
#	print('Cooldown expired')
	state = ALERT

func _reset_attack_state():
#	print('reset attack state')
	$AnimationTree.set('parameters/is_attacking/current', false)
	actions_blocked = false
