extends Area


# Declare member variables here. Examples:
export var damage = 10
export var damage_type := "melee"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_hurtbox_state(state):
	$collider.disabled = !state
	print('collider state: ', $collider.disabled)
