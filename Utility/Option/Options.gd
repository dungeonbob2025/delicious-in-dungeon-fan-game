extends VBoxContainer

@export var weapons:HBoxContainer
@export var special_weapons:HBoxContainer
@export var passive_items:GridContainer
var OptionSlot = preload("res://Utility/Option/OptionSlot.tscn")

@export var panel:NinePatchRect

const weapon_paths:Array[String] = ["res://Equipment Items/Weapon/Chilchuck/Resources/", 
									"res://Equipment Items/Weapon/Laios/Resources/", 
									"res://Equipment Items/Weapon/Marcille/Resources/", 
									"res://Equipment Items/Weapon/Sensi/Resources/"]
const special_weapon_paths:Array[String] = ["res://Equipment Items/Special Weapon/Laios/Resources/",
											"res://Equipment Items/Special Weapon/Marcille/Resources/"]
const passive_item_path:String = "res://Equipment Items/PassiveItem/Resources/"

var every_item:Array[Item] = []
var every_weapon:Array[Item] = []
var every_special_weapon:Array[Item] = []
var every_passive:Array[Item] = []

# FoodIcon을 현재 BF(Stage.gd에서 current_stage)에 맞게 제어
var food_icon_resources:Dictionary:
	set(value):
		food_icon_resources = value
var current_stage:int = 1:
	set(value):
		current_stage = value
		if food_icon_resources != null:
			current_food_icon_resources = food_icon_resources.get("BF"+str(value), [])
var current_food_icon_resources:Array

# 현재 Hide 또는 Show 상태에 따라 키보드 입력을 처리할 수 있는지 없는지 결정
# GameClear 또는 GameOver 창이 떴을 때, 1, 2, 3 버튼으로 뒤에서 게임이 실행되는 버그 막기
var is_hide:bool = true

# 기본으로 옵션 창 선택 화면은 가린 상태
func _ready():
	hide()
	panel.hide()
	is_hide = true
	get_all_item()

	food_icon_resources = load_all_food_icons("res://Utility/Option/FoodIcon/Resources/")

func close_option():
	hide()
	panel.hide()
	is_hide = true
	
	# 중요! OptionSlot을 가리더라도, 여전히 키보드 입력을 받을 수 있음 (노드가 사라진 게 아니므로)
	# 따라서, KEY_1을 계속 누르면, 해당 옵션이 계속 반영되는 버그 발생
	# (e.g. KEY_1에서 마르실 무기의 투석체 수를 +1하는 옵션이 있을 때, 옵션창이 닫혀도 KEY_1을 계속 누르면 투석체 수가 계속 증가하는 버그)
	# 이를 해결하기 위해, Option 창을 가릴 때, 모든 OptionSlot들을 queue_free한다.
	for slot in get_children():
		slot.queue_free()
	get_tree().paused = false

# HBoxContainer 노드에 있는 각 item_slot에게 item이 부여되었는지 확인
# 만약, item_slot에 item이 부여되었다면, resources에 추가
func get_available_resource_in(item_slots) -> Array[Item]:
	var resources:Array[Item] = []
	for item_slot in item_slots.get_children():
		if item_slot.item != null:
			resources.append(item_slot.item)
	return resources

func add_option(item, select_button) -> int:
	if item.is_upgradable():
		var option_slot = OptionSlot.instantiate()
		option_slot.item = item
		option_slot.select_button = select_button
		add_child(option_slot)
		return 1
	return 0

func show_option():
	is_hide = false
	
	# 기존에 있던 Options의 slot들을 삭제.
	# Option에서 보여줄 요소들이 누적되는 문제 예방.
	for slot in get_children():
		slot.queue_free()

	# 현재 '업그레이드 가능한' 장비 아이템 목록
	var available = get_equipped_item()
	# weapons HBoxContainer에서 사용할 수 있는 Slot 공간이 있다면,
	if slot_available(weapons):
		# 현재 '업그레이드 가능한' 장비 아이템 목록에 있는 것 제외하고,
		# 추가할 수 있는 weapon 장비 목록 추가
		available.append_array(get_upgradable(every_weapon, get_equipped_item()))
	# special_weapons HBoxContainer에서 사용할 수 있는 Slot 공간이 있다면,
	if slot_available(special_weapons):
		# 현재 '업그레이드 가능한' 장비 아이템 목록에 있는 것 제외하고,
		# 추가할 수 있는 special_weapon 장비 목록 추가
		available.append_array(get_upgradable(every_special_weapon, get_equipped_item()))
	# passive_items HBoxContainer에서 사용할 수 있는 Slot 공간이 있다면,
	if slot_available(passive_items):
		# 현재 '업그레이드 가능한' 장비 아이템 목록에 있는 것 제외하고,
		# 추가할 수 있는 passive_item 장비 목록 추가
		available.append_array(get_upgradable(every_passive, get_equipped_item()))
	# 랜덤 옵션을 선택할 것이니, shuffle.
	available.shuffle()
	
	# 최종적으로 선별된 '업그레이드 가능한' 장비 아이템 목록에서 앞쪽 3개 아이템만 선택 후 옵션 추가
	var select_buttons = ["KEY_1", "KEY_2", "KEY_3"]
	var option_size = 0
	for i in range(3):
		if available.size() > 0:
			option_size += add_option(available.pop_front(), select_buttons[option_size])	
	
	if option_size == 0:
		return
	
	# TextureRect_FoodIcon과 Label_Menu 변경
	var current_food_icon_resource:FoodIcon = current_food_icon_resources.pick_random()
	%TextureRect_FoodIcon.texture = current_food_icon_resource.food_texture
	%Label_Menu.text = current_food_icon_resource.food_title

	show()
	panel.show()
	get_tree().paused = true

# Path에 놓인 Resource array 탐색 후 반환 (당연히 ready 함수에서 호출해야겠지?)
func get_all_item():
	for weapon_path in weapon_paths:
		var item_resources = dir_contents(weapon_path)
		every_weapon.append_array(item_resources)
	
	for special_weapon_path in special_weapon_paths:
		var item_resources = dir_contents(special_weapon_path)
		every_special_weapon.append_array(item_resources)
	
	var item_resources = dir_contents(passive_item_path)
	every_passive.append_array(item_resources)

	every_item.append_array(every_weapon)
	every_item.append_array(every_special_weapon)
	every_item.append_array(every_passive)

func dir_contents(path):
	var dir = DirAccess.open(path)
	var item_resources = []
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if OS.has_feature("editor"):
				if file_name.ends_with(".tres"):
					var item_resource:Item = ResourceLoader.load(path + file_name, "Resource")
					item_resources.append(item_resource)				
			else:
				if file_name.ends_with(".remap"):
					file_name = file_name.replace(".remap", "")
					var item_resource:Item = ResourceLoader.load(path + file_name, "Resource")
					item_resources.append(item_resource)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return null
	return item_resources

# Weapon, Special Weapon, Passive Item을 담는 Slots에서
# 새로운 Item을 추가할 수 있는 Slot이 남아있는지 확인
func slot_available(item_slots):
	for item_slot in item_slots.get_children():
		if item_slot.item == null:
			return true
	return false

# 여기서 주목할 점은, get_upgradable 입력으로 Array[Item]를 받는다는 점.
# 즉, Item Resource 객체 형태로 관리되는데, 이러한 객체들은 GDScript에서 
# '''참조에 의한 복사''' 방식으로 값이 전달된다 (괜히 Python-like하다는 게 아니네!).
# 따라서, 한 번 읽어들인 Item 객체에서 내부 변수가 수정되면.. Item 객체의 복사 객체의
# 변수도 바뀐다는 점.. 이 점 때문에 이후 SpecialWeaponSlot에서 Item 변수가! 꼬이는 문제!
# ...가 발생한다고 생각
func get_upgradable(resources, flag = []):
	# 보통 flag는 get_equipped_item()으로 얻은 array
	var array = []
	for resource_item in resources:
		if resource_item.is_upgradable() and resource_item not in flag:
			array.append(resource_item)
	return array

# 현재 Player가 장비한 아이템 목록을 반환.
# 이때, 더이상 업그레이드 불가능한 장비(e.g. Max 레벨 도달한 아이템, Special Weapon)는 "장비한 목록"에서 배제!
# 따라서 장비한 아이템 목록 중 "업그레이드 가능한" 장비만 추려서 반환
func get_equipped_item():
	# 현재 Player가 장비한 아이템 목록 반환
	var equipped_items = get_available_resource_in(weapons)
	equipped_items.append_array(get_available_resource_in(special_weapons))
	equipped_items.append_array(get_available_resource_in(passive_items))
	
	# 장비한 아이템 목록 중 "업그레이드 가능한" 장비만 추려서 반환
	return get_upgradable(equipped_items)

func add_weapon(item):
	for slot in weapons.get_children():
		if slot.item == null:
			slot.item = item
			return

func add_special_weapon(item):
	var select_buttons = ["KEY_Q", "KEY_W", "KEY_E", "KEY_R"]
	var index = 0
	for slot in special_weapons.get_children():
		if slot.item == null:
			slot.item = item
			slot.select_button = select_buttons[index]
			return
		index += 1

func add_passive(item):
	for slot in passive_items.get_children():
		if slot.item == null:
			slot.item = item
			return

# 이미 Slot에 item이 있는지 확인
# 만약, Slot에 없었다면, item 추가
# 만약, Slot에 이미 있다면, 생략
func check_item(item):
	if item in get_available_resource_in(weapons) or item in get_available_resource_in(special_weapons) or item in get_available_resource_in(passive_items):
		return
	else:
		if item is Weapon:
			add_weapon(item)
		elif item is SpecialWeapon:
			add_special_weapon(item)
		elif item is PassiveItem:
			add_passive(item)

func load_all_food_icons(base_path:String) -> Dictionary:
	var result: Dictionary = {
		"BF1": [],
		"BF2": [],
		"BF3": [],
		"BF4": [],
		"BF5": [],
	}

	for bf_key in result.keys():
		var full_path = base_path.path_join(bf_key)
		var dir = DirAccess.open(full_path)
		
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if OS.has_feature("editor"):
					if file_name.ends_with(".tres"):
						var resource_path = full_path.path_join(file_name)
						# var resource = load(resource_path)
						var resource = ResourceLoader.load(resource_path, "Resource")
						if resource != null:
							result[bf_key].append(resource)
						else:
							print("Failed to load resource: ", resource_path)
				else:
					if file_name.ends_with(".remap"):
						file_name = file_name.replace(".remap", "")
						var resource_path = full_path.path_join(file_name)
						# var resource = load(resource_path)
						var resource = ResourceLoader.load(resource_path, "Resource")
						if resource != null:
							result[bf_key].append(resource)
						else:
							print("Failed to load resource: ", resource_path)					
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			print("Failed to open directory: " + full_path)

	return result	
