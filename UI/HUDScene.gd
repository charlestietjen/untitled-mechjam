extends Control


# Declare member variables here. Examples:
onready var health_bar = $HealthBar/HealthBar

func _on_Player_health_changed(max_health, new_health):
	var health_percentage = new_health / max_health
	health_bar.value = health_percentage * 100
