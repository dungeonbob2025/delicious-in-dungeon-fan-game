extends Item
class_name SpecialWeapon # 모든 궁극기 무기들은 SpecialWeapon을 상속받으며, 이들로부터 Resource를 만든다.

@export var damage:float
@export var description:String

@export var marcille_special_attack_node:PackedScene = preload("res://Equipment Items/Special Weapon/Marcille/Explosion.tscn")
@export var laios_special_attack_node:PackedScene = preload("res://Equipment Items/Special Weapon/Laios/MonsterBodySlam.tscn")
@export var explosion_sound:AudioStream = preload("res://Asset/5. Audio/explosion.mp3")
@export var stomp_sound:AudioStream = preload("res://Asset/5. Audio/stomp.mp3")

#@export var chilchuck_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Chilchuck/Arrow.tscn")
#@export var sensi_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Sensi/SlashArea.tscn")

# 모든 Weapon이 동작할 때마다 호출되는 activate 함수의 추상화 버전
func activate(_source, _target, _scene_tree):
	pass

# Special 무기는 level 0 <-> 1을 번갈아가면서 동작
# 문제는 level 변수를 사용할 경우, 생각보다 코드가 많이 꼬임;;
# 따라서, Item에서 special_on 변수를 설정한다.
# special_on = true << 업그레이드 불가능, slot 추가 불가
# special_on = false << 업그레이드 가능, slot 추가 가능 

# Special Weapon은 일반 Weapon이나 Passive Item과 달리
# "업그레이드 대신에 활성화 방식"과 "사용하면 Slot에서 사라지는 특성"을 가지고 있음.
# 따라서, 다른 Item들은 level을 사용해서 업그레이드 가능 여부를 테스트하는 반면,
# Special Weapon은 special_on을 사용해서 업그레이드 가능 여부를 테스트한다.
# 이는 코드를 간결하게 만들기 위함도 목적이 있다.
#		special_on = true << 업그레이드 불가능, slot 추가 불가
# 		special_on = false << 업그레이드 가능, slot 추가 가능 
func is_upgradable() -> bool:
	if not special_on:
		return true
	return false

# Special Weapon을 업그레이드(즉, 활성화)하면, special_on을 true으로 바꾼다.
# 이후 is_upgradable()은 false가 리턴되므로, 똑같은 종류의 Special Weapon이
# Option 선택지에서 보여지는 일이 없어지게 된다.
func upgrade_item():
	if not is_upgradable():
		return
	special_on = true
