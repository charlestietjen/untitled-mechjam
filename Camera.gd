extends Spatial


# Declare member variables here. Examples:
onready var player = get_parent().get_node("PlayerController")
var targetLocation = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translation.x = move_toward(translation.x, player.translation.x, 30 * delta)
	translation.y = move_toward(translation.y, player.translation.y + 2, 30 * delta)
