extends Control


# Declare member variables here. Examples:
var health_bar_start_size = 445
onready var health_bar = $HealthBar/HealthFill


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Player_health_changed(max_health, new_health):
	var health_percentage = new_health / max_health
	print(new_health, max_health, health_percentage)
	health_bar.rect_size.x = health_bar_start_size * health_percentage
