extends SpecialWeapon
class_name MarcilleSpecialWeapon

@export var select_button:String = "KEY_Q"

# Explosion을 터뜨리는 함수 => 마르실의 궁극기
func explode(source, target, scene_tree):
	if target == null:
		return
	
	var explosion = marcille_special_attack_node.instantiate()

	# Arrow 속성 설정 (Weapon Resource에서 미리 정해둔 값으로..)
	explosion.position = source.position
	explosion.damage = self.damage
	explosion.source = source

	# Arrow 노드를 씬에 추가
	SoundManager.play_sfx(explosion_sound)
	scene_tree.current_scene.add_child(explosion)
	
# 모든 SpecialWeapon들은 추상 함수 activate를 통해 활성화
func activate(source, target, scene_tree):
	explode(source, target, scene_tree)

# Weapon의 upgrade_item 오버라이딩
func upgrade_item():
	if not is_upgradable():
		return
	special_on = true
