extends Control

func _ready():
	$MenuLayer/PressStart.grab_focus()
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	$MenuLayer/controlsLayout/backButton.connect("button_up", self, "_on_controls_back_up")


func _on_PressStart_button_up():
	$MenuLayer/PressStart.visible = not visible
	$MenuLayer/Menu.visible = visible
	$MenuLayer/Menu/Start.grab_focus()


func _on_Start_button_up():
	$BGLayer/AnimationPlayer.play("transition")
	$buttonDown.play()
	$MenuLayer/Menu.visible = not visible
	yield(get_tree().create_timer(1.8), "timeout")
	SceneChanger.goto_scene("res://UI/LoadingUI.tscn")

func _on_Quit_button_up():
	$buttonDown.play()
	$MenuLayer/Menu.visible = not visible
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().quit()

func _on_focus_changed(event):
	$buttonFocus.play()


func _on_Control_button_up():
	$buttonDown.play()
	$MenuLayer/Menu.visible = not visible
	$MenuLayer/controlsLayout.visible = visible
	$MenuLayer/controlsLayout/backButton.grab_focus()

func _on_controls_back_up():
	$buttonDown.play()
	$MenuLayer/controlsLayout.visible = not visible
	$MenuLayer/Menu.visible = visible
	$MenuLayer/Menu/Control.grab_focus()
