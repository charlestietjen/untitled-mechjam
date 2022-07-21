extends Control


func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	$PauseBg/controlsDisplay/backButton.connect("button_up", self, "_on_controlsBackButton_button_up")

func _on_resumeButton_button_up():
	$buttonDown.play()
	visible = not visible
	get_tree().paused = false

func _on_controlsButton_button_up():
	$buttonDown.play()
	$PauseBg/menu.visible = not visible
	$PauseBg/controlsDisplay.visible = visible
	$PauseBg/controlsDisplay/backButton.grab_focus()

func _on_quitButton_button_up():
	$buttonDown.play()
	$PauseBg/quitConfirm.visible = visible
	$PauseBg/quitConfirm/noButton.grab_focus()

func _on_controlsBackButton_button_up():
	$buttonDown.play()
	$PauseBg/controlsDisplay.visible = not visible
	$PauseBg/menu.visible = visible
	$PauseBg/menu/controlsButton.grab_focus()

func _on_yesButton_button_up():
	$buttonDown.play()
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().quit()

func _on_noButton_button_up():
	$buttonDown.play()
	$PauseBg/quitConfirm.visible = not visible
	$PauseBg/menu/quitButton.grab_focus()

func _on_Control_visibility_changed():
	if visible == visible:
		$PauseBg/menu/resumeButton.grab_focus()

func _on_gui_focus_changed(_event):
	$focusChange.play()
