extends KinematicBody2D


# Declare member variables here. Examples:
export var acceleration = 0.1
export var maxSpeed = 60
export var boostSpeed = 2
var targetSpeed
var inputVelocity = Vector2()
var velocity = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	inputVelocity.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	inputVelocity.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	inputVelocity = inputVelocity.normalized()
	if Input.is_action_pressed("boost"):
		targetSpeed = maxSpeed * boostSpeed
	else:
		targetSpeed = maxSpeed
	velocity.x = lerp(velocity.x, targetSpeed  * inputVelocity.x, acceleration)
	velocity.y = lerp(velocity.y, targetSpeed * inputVelocity.y, acceleration)
	velocity = move_and_slide(velocity, Vector2.UP)
