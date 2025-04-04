extends SpecialWeapon
class_name LaiosSpecialWeapon

@export var select_button:String = "KEY_W"

# Explosion을 터뜨리는 함수 => 마르실의 궁극기
func slam(source, target, scene_tree):
	if target == null:
		return
	
	var bodyslam = laios_special_attack_node.instantiate()

	# Arrow 속성 설정 (Weapon Resource에서 미리 정해둔 값으로..)
	bodyslam.position = source.position
	bodyslam.damage = self.damage
	bodyslam.source = source

	# Arrow 노드를 씬에 추가
	scene_tree.current_scene.add_child(bodyslam)
	SoundManager.play_sfx(stomp_sound)
	
# 모든 SpecialWeapon들은 추상 함수 activate를 통해 활성화
func activate(source, target, scene_tree):
	slam(source, target, scene_tree)

# Weapon의 upgrade_item 오버라이딩
func upgrade_item():
	if not is_upgradable():
		return
	special_on = true
