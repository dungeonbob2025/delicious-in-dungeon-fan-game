extends Weapon
class_name Circular

@export var angular_speed = 20	# 회전 속도
@export var radius = 20			# 회전 반경
@export var amount = 1			# 회전하는 Projectile 개수

var projectile_reference:Array[Area2D]	# Projectile 노드 담는 변수
var angle:float							# 현재 각도

# 상위 Weapon 클래스에서 받은 추상 메소드
func activate(source, _target, _scene_tree):
	reset()
	for i in range(amount):
		add_to_player(source)

# SingleShot의 shoot과는 다르게, add_to_player를 통해 Projectile 생성
func add_to_player(source):
	var projectile = marcille_projectile_node.instantiate()
	
	projectile.speed = 0	# Linear Speed는 0으로 설정. 우리는 앞으로 쏘는 공격이 아니니까
	projectile.damage = damage
	projectile.source = source
	projectile.hide()
	
	projectile_reference.append(projectile)
	source.call_deferred("add_child", projectile)

func update(delta):
	angle += angular_speed * delta
	
	# 현재 projectile_reference에 저장된 projectile 위치를 직접 업데이트
	#print(projectile_reference.size())
	for i in range(projectile_reference.size()):
		if is_instance_valid(projectile_reference[i]):
			var offset = i * (360.0 / amount)
			
			projectile_reference[i].position = radius * Vector2(cos(deg_to_rad(angle + offset)), sin(deg_to_rad(angle + offset)))
			
			projectile_reference[i].show()

# Circular 무기는 Projectile이 추가될 때마다 reset 후 새롭게 그리는 방식으로 진행
# 상당히 직관적인 구현 방식이라서 간편!
func reset():
	while projectile_reference.size() > 0:
		if is_instance_valid(projectile_reference[-1]):
			projectile_reference.pop_back().queue_free()
		else:
			projectile_reference.pop_back()
		
func upgrade_item():
	if not is_upgradable():
		return

	if level == 0:
		level += 1
		return

	var upgrade = upgrades[level]
	angular_speed *= upgrade.angular_speed
	amount += upgrade.amount
	radius *= upgrade.radius
	damage *= upgrade.damage
	cooldown *= upgrade.cooldown
	
	level += 1
