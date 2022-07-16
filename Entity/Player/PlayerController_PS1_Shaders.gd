extends "res://script/Actor.gd"

export var _boost_speed = 2.5
export var _initial_boost = 10
var _new__velocity
var _input_velocity = Vector3.ZERO
var _velocity = Vector3(0,0,0)
var _is_attacking = false
var _combo_enabled = false
var _is_boosting = false
var _current_attack = 0

func _ready():
	health = maxHealth
	$AnimTree.active = true

func _process(_delta):
	_input_velocity = Vector2.ZERO
	_input_velocity.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	_input_velocity.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	if _input_velocity.x > 0:
		rotation.y = lerp_angle(rotation.y, 90, 0.5)
	elif _input_velocity.x < 0:
		rotation.y = lerp_angle(rotation.y, 180, 0.5)
	if _input_velocity != Vector2.ZERO:
		$AnimTree.set('parameters/is_moving/current', 1)
	else:
		$AnimTree.set('parameters/is_moving/current', 0)
	$AnimTree.set("parameters/is_boosting/current", _is_boosting)
	$AnimTree.set('parameters/move_direction/blend_position', Vector2(_velocity.x, _velocity.y))
	_input_velocity = _input_velocity.normalized()
	if Input.is_action_just_pressed("boost"):
		_new__velocity = speed * (_boost_speed + _initial_boost)
	elif Input.is_action_pressed("boost"):
		_new__velocity = speed * _boost_speed
		_is_boosting = true
	else:
		_is_boosting = false
		_new__velocity = speed
	if !_is_attacking:
		_velocity.x = lerp(_velocity.x, _new__velocity  * _input_velocity.x, acceleration)
		_velocity.y = lerp(_velocity.y, _new__velocity * _input_velocity.y, acceleration)
	else:
		_velocity.x = lerp(_velocity.x, 0, acceleration)
		_velocity.y = lerp(_velocity.y, 0, acceleration)
	global_transform.origin.z = 0
	_velocity = move_and_slide(_velocity, Vector3.DOWN)
#	if Input.is_action_just_pressed("attack") && _is_attacking:
#		currentAttack = clamp(currentAttack, -1, 2)
#		currentAttack += 1
#		$AnimTree.set('parameters/attack_state/current', currentAttack)
	if Input.is_action_just_pressed("attack") && _combo_enabled:
		print('Follow up attack: ', _current_attack)
		print(rotation.y)
		if rotation.y < 0:
			_velocity.x -= 20
		elif rotation.y > 0:
			_velocity.x += 20
		$AnimTree.set('parameters/attack_state/current', _current_attack)
		_combo_enabled = false
	elif Input.is_action_just_pressed("attack") && !_is_attacking:
		if rotation.y < 0:
			_velocity.x -= 20
		elif rotation.y > 0:
			_velocity.x += 20
		print('Combo start at: ', _current_attack)
		_is_attacking = true
		_combo_enabled = false
		$AnimTree.set('parameters/blocked_action/current', true)
		$AnimTree.set('parameters/action_type/current', 0)
		$AnimTree.set('parameters/attack_state/current', _current_attack)
	elif Input.is_action_pressed("block") && !_is_attacking:
		$AnimTree.set('parameters/blocked_action/current', true)
		$AnimTree.set("parameters/action_type/current", 1)
		$shield.visible = visible
	elif Input.is_action_just_released("block") && !_is_attacking:
		$shield.visible = not visible
		$AnimTree.set('parameters/blocked_action/current', false)
#	set debug label to display current vectors
	$debugLabel.text = str(int(_velocity.x),' ',int(_velocity.y))
	
func _reset_attack_state():
	print('reset attack state')
	_current_attack = 0
	$AnimTree.set('parameters/blocked_action/current', false)
	_is_attacking = false
	_combo_enabled = false
	
func _enable_combo():
	print('combo window open')
	_combo_enabled = true
	_current_attack = wrapi(_current_attack, 0, 2)
	_current_attack += 1
