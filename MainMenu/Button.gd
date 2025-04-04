extends Button

@onready var click_sound:AudioStream = preload("res://Asset/5. Audio/button_click.mp3")

func _on_pressed():
	SoundManager.play_sfx(click_sound)
	if Persistence.character != null:
		get_tree().change_scene_to_file("res://Stage/Stage.tscn")
