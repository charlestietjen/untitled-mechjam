extends "res://script/Actor.gd"

signal health_changed(max_health, new_health)

onready var target_element_scene = preload("res://Entity/UI/TargetElement.tscn")
onready var bullet_scene = preload("res://Entity/Weapon/PlayerBullet.tscn")
export var boostspeed := 2.5
export var initial_boost := 10
export var melee_range := 30.0
var input_direction := Vector2.ZERO
var velocity := Vector3(0,0,0)
var is_attacking := false
var combo_enabled := false
var is_blocking := false
var is_boosting := false
var current_attack := 0
var target_element = null
var target_list := []
var target = null
var pause_enabled = true

func _ready():
	pass

func _process(_delta):
	var new_speed
	if !is_instance_valid(target):
		target = null
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
#	if we don't have a target then we lerp our facing angle to full left or right based on input
	if input_direction.x > 0 && !target:
		rotation.y = lerp_angle(rotation.y, 1, 0.5)
	elif input_direction.x < 0 && !target:
		rotation.y = lerp_angle(rotation.y, -1, 0.5)
#	if we do have a target, we rotate to face the target (this is a little janky currently when rotating full around a target
	if target:
#		rotation.x = stepify(rotation.x, 0.01)
#		rotation.x = clamp(rotation.x, -0.9, 0.9)
		look_at(target.global_transform.origin, Vector3.UP)
		rotate_object_local(Vector3.DOWN, PI)
		rotation.x = clamp(rotation.x, -0.8, 0.8)
	else:
		rotation.x = lerp_angle(rotation.x, 0, 0.1)
#	flag the character as moving or not in the animation tree
	if input_direction != Vector2.ZERO:
		$AnimationTree.set('parameters/is_moving/current', 1)
		$armatureMaterialTest/Skeleton/torsoAttachments/engineTrailLeft.emitting = true
		$armatureMaterialTest/Skeleton/torsoAttachments/engineTrailRight.emitting = true
	else:
		$armatureMaterialTest/Skeleton/torsoAttachments/engineTrailLeft.emitting = false
		$armatureMaterialTest/Skeleton/torsoAttachments/engineTrailRight.emitting = false
		$AnimationTree.set('parameters/is_moving/current', 0)
#	set whether the character is boosting and set the blend position of the movement direction to
#	our current velocity, this manages vertical and horizontal movement animations
	$AnimationTree.set("parameters/is_boosting/current", is_boosting)
	$AnimationTree.set('parameters/move_direction/blend_position', Vector2(velocity.x, velocity.y))
#	normalize the input velocity to prevent diagonal movement being faster than single axis
	input_direction = input_direction.normalized()
#	go faster decider
	if Input.is_action_just_pressed("boost") && !is_blocking:
		new_speed = speed * (boostspeed + initial_boost)
	elif Input.is_action_pressed("boost") && !is_blocking:
		new_speed = speed * boostspeed
		is_boosting = true
	else:
		is_boosting = false
		new_speed = speed
#	if we're not currently attacking, lerp the velocity towards speed at a rate of acceleration
	if !is_attacking:
		velocity.x = lerp(velocity.x, new_speed  * input_direction.x, acceleration)
		velocity.y = lerp(velocity.y, new_speed * input_direction.y, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, acceleration)
		velocity.y = lerp(velocity.y, 0, acceleration)
#	manage attack state, animations call methods to set which if statement executes, if the target
#	is within the defined melee range, move towards them and attack, else -> shoot in future
	if Input.is_action_just_pressed("attack") && combo_enabled:
		if !target:
			pass
		else:
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			if distance_to_target < melee_range:
#				print('Follow up attack: ', current_attack)
				$AnimationTree.set('parameters/attack_state/current', current_attack)
				velocity = (target.global_transform.origin - global_transform.origin) * 5
				combo_enabled = false
	elif Input.is_action_just_pressed("attack") && !is_attacking && !is_blocking:
		if !target:
			pass
			is_attacking = true
			$AnimationTree.set("parameters/blocked_action/current", true)
			$AnimationTree.set("parameters/action_type/current", 2)
		else:
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			if distance_to_target < melee_range:
#				print('Combo start at: ', current_attack)
				is_attacking = true
				combo_enabled = false
				$AnimationTree.set('parameters/blocked_action/current', true)
				$AnimationTree.set('parameters/action_type/current', 0)
				$AnimationTree.set('parameters/attack_state/current', current_attack)
				velocity = (target.global_transform.origin - global_transform.origin) * 5
			else:
				is_attacking = true
				$AnimationTree.set("parameters/blocked_action/current", true)
				$AnimationTree.set("parameters/action_type/current", 2)
#	if we're not attacking and hold block, we're blocking
	elif Input.is_action_pressed("block") && !is_attacking:
		velocity = velocity * 0.8
		$AnimationTree.set('parameters/blocked_action/current', true)
		$AnimationTree.set("parameters/action_type/current", 1)
		$shield.visible = visible
		is_blocking = true
	elif Input.is_action_just_released("block") && !is_attacking:
		$shield.visible = not visible
		$AnimationTree.set('parameters/blocked_action/current', false)
		is_blocking = false
	global_transform.origin.z = 0
	velocity = move_and_slide(velocity, Vector3.DOWN)
	if Input.is_action_just_pressed("toggle_target"):
		_target_toggle()
	if Input.is_action_just_pressed("next_target"):
		_target_change(1)
	elif Input.is_action_just_pressed("previous_target"):
		_target_change(-1)
	if Input.is_action_just_pressed("pause") && pause_enabled:
		get_node("/root/Spatial/pauseGUI").visible = visible
		get_tree().paused = true
	
func _reset_attack_state():
#	print('reset attack state')
	current_attack = 0
	$AnimationTree.set('parameters/blocked_action/current', false)
	is_attacking = false
	combo_enabled = false
	
func _enable_combo():
#	print('combo window open')
	combo_enabled = true
	current_attack = wrapi(current_attack, 0, 2)
	current_attack += 1

func _target_toggle():
	if !target:
		var closest_target
		var target_distance := 0.0
		for i in target_list.size():
			if is_instance_valid(target_list[i]):
				var distance_to_target = global_transform.origin.distance_to(target_list[i].global_transform.origin)
				if !closest_target:
					closest_target = target_list[i]
					target_distance = distance_to_target
				elif distance_to_target < target_distance:
					closest_target = target_list[i]
					target_distance = distance_to_target
		if !closest_target:
			return
		target = closest_target
		target_element = target_element_scene.instance()
		target.add_child(target_element)
	else:
		target = null
		if is_instance_valid(target_element):
			target_element.queue_free()
			
func _target_change(offset):
	var new_target = null
	if target_list.size() < 1:
		return
	if !target:
		return
	var i = target_list.find(target)
	if i > -1:
			new_target = target_list[wrapi((i) + offset, 0, target_list.size() - 1)]
	else:
		pass
	if is_instance_valid(target_element):
		target_element.queue_free()
	target = new_target
	if is_instance_valid(target):
		target_element = target_element_scene.instance()
		target.add_child(target_element)
		
func _apply_knockback(knockback_velocity : Vector3):
	velocity = knockback_velocity

func shoot():
	var bullet = bullet_scene.instance()
#	var bullet_velocity = Vector3(0, 0, 5).rotated(rotation, 0)
	$armatureMaterialTest/Skeleton/rightHandAttachments.add_child(bullet)
	if is_instance_valid(target):
		bullet.look_at(target.global_transform.origin, Vector3.FORWARD)
	else:
		bullet.rotation.y = -rotation.y * 1.5
#	var bullet_direction = global_transform.basis.xform(Vector3.FORWARD)
#	print(bullet_direction)
#	bullet.rotation = bullet_direction
	bullet.velocity = Vector3(0,0,-30)

func _on_targetArea_body_entered(body):
	if body != null:
		target_list.push_front(body)


func _on_targetArea_body_exited(body):
	if body != null:
		for i in target_list.size():
			if target_list[i - 1] == body && i > 0:
				target_list.remove(i - 1)


func _on_hitbox_area_entered(area):
	if area.damage_type == "range":
		if !is_blocking:
			$meleeHitSfx.play()
			damage_health(area.damage)
			emit_signal("health_changed", maxHealth, health)
			$AnimationTree.set("parameters/on_hit/active", true)
			$hitbox/hitboxCollider.disabled = true
			$invulTimer.start()
		else:
			pass
		area.get_parent().queue_free()
	elif area.damage_type == "melee":
		if !is_blocking:
			$meleeHitSfx.play()
			damage_health(area.damage)
			emit_signal("health_changed", maxHealth, health)
			$AnimationTree.set("parameters/on_hit/active", true)
			$hitbox/hitboxCollider.disabled = true
			$invulTimer.start()
		else:
			pass


func _on_invulTimer_timeout():
	$hitbox/hitboxCollider.disabled = false

func handle_game_over():
	get_tree().change_scene("res://UI/YouDiedUI.tscn")
