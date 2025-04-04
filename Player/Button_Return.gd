extends Button

func _on_pressed():
	get_tree().paused = false
	Persistence.character = null
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
