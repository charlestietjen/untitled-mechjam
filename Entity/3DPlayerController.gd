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


# Called when the node enters the scene tree for the first time.
func _ready():
	$valkyrie/AnimTree.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if int(velocity.x) > 0:
		$valkyrie/AnimTree.set('parameters/move_state/current', 1)
		rotation.y = lerp_angle(rotation.y, 90, 0.5)
	elif int(velocity.x) < 0:
		$valkyrie/AnimTree.set('parameters/move_state/current', 1)
		rotation.y = lerp_angle(rotation.y, 180, 0.5)
	else:
		$valkyrie/AnimTree.set('parameters/move_state/current', 0)
	inputVelocity.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	inputVelocity.y = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	inputVelocity = inputVelocity.normalized()
	if Input.is_action_just_pressed("boost"):
		targetSpeed = maxSpeed * (boostSpeed + initialBoost)
	elif Input.is_action_pressed("boost"):
		targetSpeed = maxSpeed * boostSpeed
	else:
		targetSpeed = maxSpeed
	velocity.x = lerp(velocity.x, targetSpeed  * inputVelocity.x, acceleration)
	velocity.y = lerp(velocity.y, targetSpeed * inputVelocity.y, acceleration)
	velocity = move_and_slide(velocity, Vector3.UP)
#	set debug label to display current vectors
	$debugLabel.text = str(int(velocity.x),' ',int(velocity.y))
