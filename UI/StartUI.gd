extends Control


func _ready():
	$PressStart.grab_focus()


func _on_PressStart_button_up():
	$PressStart.visible = not visible
	$Menu.visible = visible
	$Menu/Start.grab_focus()


func _on_Start_button_up():
	SceneChanger.goto_scene("res://UI/LoadingUI.tscn")


func _on_Quit_button_up():
	get_tree().quit()
