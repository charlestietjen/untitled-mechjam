extends Control

func _ready():
	$Restart.grab_focus()

func _on_Restart_button_up():
	SceneChanger.goto_scene("res://Map/SkyMapTest.tscn")

func _on_Quit_button_up():
	get_tree().quit()
