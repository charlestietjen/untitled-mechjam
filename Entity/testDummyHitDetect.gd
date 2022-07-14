extends Area


# Declare member variables here. Examples:
export var maxHealth = 100
var health

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if health == 0:
		queue_free()




func _on_testDummy_area_entered(area):
	damage_health(area.damage)

func damage_health(damage):
	health = clamp(health, 0, maxHealth)
	health -= damage
