extends KinematicBody


# Declare member variables here. Examples:
export var acceleration = 0.1
export var maxSpeed = 60
export var boostSpeed = 2.5
export var initialBoost = 10
export var gravity = 30
var targetSpeed
var inputVelocity = Vector3(0,0,0)
var velocity = Vector3(0,0,0)
var is_attacking = false
var combo_valid = false
var currentAttack = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimTree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if int(velocity.x) > 0:
		$AnimTree.set('parameters/move_state/current', 1)
		rotation.y = lerp_angle(rotation.y, 90, 0.5)
	elif int(velocity.x) < 0:
		$AnimTree.set('parameters/move_state/current', 1)
		rotation.y = lerp_angle(rotation.y, 180, 0.5)
	else:
		$AnimTree.set('parameters/move_state/current', 0)
	inputVelocity.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	inputVelocity.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	inputVelocity = inputVelocity.normalized()
	if Input.is_action_just_pressed("boost"):
		targetSpeed = maxSpeed * (boostSpeed + initialBoost)
	elif Input.is_action_pressed("boost"):
		targetSpeed = maxSpeed * boostSpeed
	else:
		targetSpeed = maxSpeed
	if !is_attacking:
		velocity.x = lerp(velocity.x, targetSpeed  * inputVelocity.x, acceleration)
		velocity.y = lerp(velocity.y, targetSpeed * inputVelocity.y, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, acceleration)
		velocity.y = lerp(velocity.y, 0, acceleration)
	global_transform.origin.z = 0
	velocity = move_and_slide(velocity, Vector3.UP)
#	if Input.is_action_just_pressed("attack") && is_attacking:
#		currentAttack = clamp(currentAttack, -1, 2)
#		currentAttack += 1
#		$AnimTree.set('parameters/attack_state/current', currentAttack)
	if Input.is_action_just_pressed("attack") && combo_valid:
		print('Follow up attack: ', currentAttack)
		$AnimTree.set('parameters/attack_state/current', currentAttack)
		combo_valid = false
	elif Input.is_action_just_pressed("attack") && !is_attacking:
		print('Combo start at: ', currentAttack)
		is_attacking = true
		combo_valid = false
		$AnimTree.set('parameters/is_attacking/current', true)
		$AnimTree.set('parameters/attack_state/current', currentAttack)
#	set debug label to display current vectors
	$debugLabel.text = str(int(velocity.x),' ',int(velocity.y))
	
func _reset_attack_state():
	print('reset attack state')
	currentAttack = 0
	$AnimTree.set('parameters/is_attacking/current', false)
	is_attacking = false
	combo_valid = false
	
func _enable_combo():
	print('combo window open')
	combo_valid = true
	currentAttack = wrapi(currentAttack, 0, 2)
	currentAttack += 1
