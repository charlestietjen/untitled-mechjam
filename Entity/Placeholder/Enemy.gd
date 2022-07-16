extends KinematicBody


# Declare member variables here. Examples:
export var acceleration = 0.1
export var floatSpeed = 1
export var boostSpeed = 2.5
export var initialBoost = 10
export var gravity = 30

var velocity = Vector3(0,0,0)

var path = []
var pathNode = 0

onready var nav = get_parent()
onready var player = $"../../PlayerController"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if pathNode < path.size():
		var direction = (path[pathNode] - global_transform.origin)
		
		if direction.length() < 1:
			pathNode += 1
		else:
			move_and_slide(direction.normalized() * floatSpeed, Vector3.UP)

func move_to(target_pos):
	if (!nav):
		return
	path = nav.get_simple_path(global_transform.origin, target_pos)
	pathNode = 0


func _on_Timer_timeout():
	if(!player):
		return
	move_to(player.global_transform.origin)
