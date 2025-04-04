extends Panel

var icon = null:
	set(value):
		icon = value
		$TextureButton.texture_normal = value

signal pressed

func _ready():
	$Line2D_Select.hide()

func _on_texture_button_pressed():
	for slot in get_parent().get_children():
		slot.deselect()
		
	$Line2D_Select.show()
	pressed.emit()

func deselect():
	$Line2D_Select.hide()
