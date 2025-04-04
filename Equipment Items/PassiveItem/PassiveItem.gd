extends Item
class_name PassiveItem

@export var upgrades:Array[Stats]
var player_reference # PassiveItem 업그레이드는 즉시 Player 속성 변수로 반영

# Weapon과 동일한 형태로 동작
func is_upgradable() -> bool:
	# 레벨 0부터 시작하니까.. level - 1을 하면, 마지막 요소를 참조
	# 따라서, Weapon과 달리 [level]을 사용한다.
	# 그러므로 upgrade 최대 횟수를 계산할 때, <= 가 아니라 <를 사용한다.
	if level < upgrades.size():
		return true
	return false

func upgrade_item():
	if not is_upgradable():
		return
		
	if player_reference == null:
		return
	
	# 레벨 0부터 시작하니까.. level - 1을 하면, 마지막 요소를 참조
	# 따라서, Weapon과 달리 [level]을 사용한다.
	var upgrade = upgrades[level]
	
	player_reference.speed *= upgrade.speed_stats
	player_reference.normal_damage *= upgrade.normal_damage_stats
	player_reference.critical_damage *= upgrade.critical_damage_stats
	player_reference.XP_growth *= upgrade.XP_growth_stats
	player_reference.area *= upgrade.area_stats
	player_reference.magnet *= upgrade.magnet_stats
	
	level += 1
