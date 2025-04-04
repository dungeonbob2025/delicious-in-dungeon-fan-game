extends Item
class_name Weapon # 모든 무기들은 Weapon을 상속받으며, 
				  # 무기들(e.g. SingleShot) 클래스로 Resource를 만든다.

@export var damage:float
@export var cooldown:float
@export var speed:float

@export var marcille_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Marcille/Projectile.tscn")
@export var chilchuck_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Chilchuck/Arrow.tscn")
@export var laios_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Laios/SlashArea.tscn")
@export var sensi_projectile_node:PackedScene = preload("res://Equipment Items/Weapon/Sensi/SlashArea.tscn")

# Upgrade 리스트와 시작 무기 level
@export var upgrades:Array[Upgrade]

# 모든 Weapon이 동작할 때마다 호출되는 activate 함수의 추상화 버전
func activate(_source, _target, _scene_tree):
	pass

# 지금 무기를 계속 업그레이드할 수 있는지 확인
func is_upgradable() -> bool:
	if level < upgrades.size():
		return true
	return false
	
func upgrade_item():
	if not is_upgradable():
		return
	
	if level == 0:
		level += 1
		return

	var upgrade = upgrades[level]
	
	# 기본적으로 데미지, 쿨다운 등 업그레이드할 수 있는 내용을 업그레이드
	damage += upgrade.damage
	cooldown += upgrade.cooldown
	
	level += 1
