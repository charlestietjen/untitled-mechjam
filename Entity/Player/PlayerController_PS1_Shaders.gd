extends "res://script/Actor.gd"

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
var target = null
var target_list := []

func _ready():
	health = maxHealth
	$AnimTree.active = true
	var testDummy = get_parent().get_node("testDummy")
	target_list = [testDummy]

func _process(_delta):
	var new_speed
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	input_direction.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
#	if we don't have a target then we lerp our facing angle to full left or right based on input
	if input_direction.x > 0 && !target:
		rotation.y = lerp_angle(rotation.y, -1, 0.5)
	elif input_direction.x < 0 && !target:
		rotation.y = lerp_angle(rotation.y, 1, 0.5)
#	if we do have a target, we rotate to face the target (this is a little janky currently when rotating full around a target
	if target:
#		rotation.x = stepify(rotation.x, 0.01)
#		rotation.x = clamp(rotation.x, -0.9, 0.9)
		look_at(target.global_transform.origin, Vector3.DOWN)
		rotation.x = clamp(rotation.x, -0.8, 0.8)
#	flag the character as moving or not in the animation tree
	if input_direction != Vector2.ZERO:
		$AnimTree.set('parameters/is_moving/current', 1)
	else:
		$AnimTree.set('parameters/is_moving/current', 0)
#	set whether the character is boosting and set the blend position of the movement direction to
#	our current velocity, this manages vertical and horizontal movement animations
	$AnimTree.set("parameters/is_boosting/current", is_boosting)
	$AnimTree.set('parameters/move_direction/blend_position', Vector2(velocity.x, velocity.y))
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
				print('Follow up attack: ', current_attack)
				velocity = (target.global_transform.origin - global_transform.origin) * 5
				$AnimTree.set('parameters/attack_state/current', current_attack)
				combo_enabled = false
	elif Input.is_action_just_pressed("attack") && !is_attacking && !is_blocking:
		if !target:
			pass
		else:
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			if distance_to_target < melee_range:
				print('Combo start at: ', current_attack)
				velocity = (target.global_transform.origin - global_transform.origin) * 5
				is_attacking = true
				combo_enabled = false
				$AnimTree.set('parameters/blocked_action/current', true)
				$AnimTree.set('parameters/action_type/current', 0)
				$AnimTree.set('parameters/attack_state/current', current_attack)
			else:
				print('shoot placeholder')
#	if we're not attacking and hold block, we're blocking
	elif Input.is_action_pressed("block") && !is_attacking:
		velocity = velocity * 0.8
		$AnimTree.set('parameters/blocked_action/current', true)
		$AnimTree.set("parameters/action_type/current", 1)
		$shield.visible = visible
		is_blocking = true
	elif Input.is_action_just_released("block") && !is_attacking:
		$shield.visible = not visible
		$AnimTree.set('parameters/blocked_action/current', false)
		is_blocking = false
	global_transform.origin.z = 0
	velocity = move_and_slide(velocity, Vector3.DOWN)
#	set debug label to display current vectors
	$debugLabel.text = str(int(velocity.x),' ',int(velocity.y))
	if Input.is_action_just_pressed("toggle_target"):
		_target_toggle()
	
func _reset_attack_state():
	print('reset attack state')
	current_attack = 0
	$AnimTree.set('parameters/blocked_action/current', false)
	is_attacking = false
	combo_enabled = false
	
func _enable_combo():
	print('combo window open')
	combo_enabled = true
	current_attack = wrapi(current_attack, 0, 2)
	current_attack += 1

func _target_toggle():
	if !target:
		for i in target_list.size():
			print(target_list[i])
	else:
		target = null
