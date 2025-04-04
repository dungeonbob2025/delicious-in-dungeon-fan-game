extends PanelContainer

var rainbow_special_weapon_material = preload("res://Shader/Weapon/SpecialWeapon.tres")

# Special Weapon 별 선택 버튼
@export var select_button:String:
	set(value):
		select_button = value

# Special Slot에 할당될 SpecialWeapon 변수
@export var item:SpecialWeapon:
	set(value):
		item = value
		if value == null:
			select_button = ""
			$TextureRect.texture = null
			$TextureRect.material = null
		else:
			select_button = value.select_button
			$TextureRect.texture = value.texture
			$TextureRect.material = rainbow_special_weapon_material

# 정말 중요한 로직을 발견했기 때문에 장문으로 설명한다.
# item.activate를 통해 현재 Slot에 지정된 Weapon을 실행한다.
# Weapon을 실행한 뒤, item.special_on = false으로 지정한다.
# 만약, item.special_on = false을 하지 않게 되면.. 문제가 발생한다.
# 이유는 아래와 같다.
#	item이 가리키는 SpecialWeapon은, Option에서 every_weapons으로 
#	읽어온 SpecialWeapon와 동일하다. 그 이유는, Slot에 SpecialWeapon을
#	지정할 때, "call-by-reference" 형태로 값을 참조하기 때문이다.
#	따라서, 여기서 item.special_on = false를 해야만, Option에 있는
#	SpecialWeapon도 special_on이 false으로 읽어오게 된다.
#	즉! 그냥 null 처리한다고 되는 문제가 아니란 소리다.
#	
#	그러면, 왜 이렇게 해야할까? 답은 간단하다.
#	special_on = false가 되어야, Option에서 is_upgradable을 확인할 때
#	true를 반환할 수 있기 때문이다. 만약, special_on = false이 없다면
#	Option에서 해당 SpecialWeapon의 is_upgradable을 확인할 때
#	여전히 special_on == true이라서, 다시는 Option에 추가하지 않을 것이다.
func _input(event):
	if select_button and event.is_action_pressed(select_button) and item:
		item.activate(owner, owner.nearest_enemy, get_tree())
		item.special_on = false
		item = null
