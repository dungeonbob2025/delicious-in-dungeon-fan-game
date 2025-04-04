extends Weapon
class_name ArrowShot

# Arrow를 쏘는 함수 => 대체로 Marcille과 거의 같음
func shoot(source, target, scene_tree):
	if target == null or scene_tree.paused == true:
		return
	
	var arrow = chilchuck_projectile_node.instantiate()

	# Arrow 속성 설정 (Weapon Resource에서 미리 정해둔 값으로..)
	arrow.position = source.position
	arrow.damage = self.damage
	arrow.speed = self.speed
	arrow.source = source
	arrow.direction = (target.position - source.position).normalized()
	arrow.rotation = arrow.direction.normalized().angle() + deg_to_rad(90)
	# Arrow 노드를 씬에 추가
	scene_tree.current_scene.add_child(arrow)
	
# 모든 Weapon들은 추상 함수 activate를 통해 활성화
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)

# Weapon의 upgrade_item 오버라이딩
func upgrade_item():
	if not is_upgradable():
		return
		
	if level == 0:
		level += 1
		return

	var upgrade = upgrades[level]
	
	speed *= upgrade.speed
	damage *= upgrade.damage
	cooldown *= upgrade.cooldown
	# Upgrade 리소스에 따라 달라지는 업그레이드 옵션
	
	level += 1
	
