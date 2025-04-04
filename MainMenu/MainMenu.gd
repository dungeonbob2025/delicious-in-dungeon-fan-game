extends Control

@export var click_sound:AudioStream

func _on_panel_title_screen_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			SoundManager.play_sfx(click_sound)
			%Panel_TitleScreen.hide()
			%Panel_CharacterSelect.show()
