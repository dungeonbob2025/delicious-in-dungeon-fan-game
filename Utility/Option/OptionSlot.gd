extends NinePatchRect

# 키보드로 선택할 때, 각 옵션 슬롯 별 부여된 번호. e.g. 키보드 1번 버튼 => One
var select_button:String

var rainbow_special_weapon_material = preload("res://Shader/Weapon/SpecialWeapon.tres")
@export var item:Item:
	set(value):
		item = value
		if item is SpecialWeapon:
			$Option_TextureIcon.texture = value.texture
			$Option_TextureIcon.material = rainbow_special_weapon_material
			$Option_Level.text = "SPECIAL"
			$Option_Description.text = value.description
		else:
			$Option_TextureIcon.texture = value.texture
			if item.level == value.upgrades.size():
				$Option_Level.text = "Lv MAX"
			else:
				$Option_Level.text = "Lv " + str(item.level + 1)
			$Option_Description.text = value.upgrades[value.level].description

func _input(event):
	# 1, 2, 3 키보드 누름에 따라 옵션 선택하도록 조정
	if event.is_action_pressed(select_button) and item:
		# 여기서 get_parent()는 Player UI에서 Options(VBOX) 노드
		get_parent().check_item(item)
		item.upgrade_item()
		get_parent().close_option() # 옵션 창 끄기
