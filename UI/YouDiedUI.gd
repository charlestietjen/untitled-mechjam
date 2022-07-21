extends Control

func _ready():
	$Restart.grab_focus()

func _on_Restart_button_up():
	get_tree().change_scene("res://UI/LoadingUI.tscn")
	
func _on_Quit_button_up():
	get_tree().quit()
