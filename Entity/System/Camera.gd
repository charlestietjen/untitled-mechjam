extends Spatial


# Declare member variables here. Examples:
onready var player = get_parent().get_node("Player")
export var pan_speed = 30
var targetLocation = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(player):
		translation.x = move_toward(translation.x, player.translation.x, pan_speed * delta)
		translation.y = move_toward(translation.y, player.translation.y + 2, pan_speed * delta)
