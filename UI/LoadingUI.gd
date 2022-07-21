extends Control

var scene_instance = null

func _ready():
	SceneChanger.connect("load_complete", self, "_on_load_complete")

func _on_Timer_timeout():
	SceneChanger.goto_scene("res://Map/SkyMapTest.tscn")

func _on_load_complete(instance):
	scene_instance = instance
	$loadingLabel.visible = not visible
	$continueButton.visible = visible
	$continueButton.grab_focus()


func _on_continueButton_button_up():
	SceneChanger.change_scene(scene_instance)
