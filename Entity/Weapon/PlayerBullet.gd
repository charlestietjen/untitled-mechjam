extends KinematicBody


export var damage := 5
export var bullet_speed := 5

var velocity

func _ready():
	set_as_toplevel(true)

func _process(_delta):
	move_and_slide(transform.basis * velocity)
