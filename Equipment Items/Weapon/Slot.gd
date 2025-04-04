extends PanelContainer

# Slot에 할당될 기본 Weapon
@export var item:Weapon:
	set(value):
		item = value
		$TextureRect.texture = value.texture
		$Timer_Cooldown.wait_time = value.cooldown

# 마르실 공격처럼, 일정 시간마다 무기 위치를 임의로 계산하는 경우엔
# _physics_process 내부에서 item의 update 함수 호출
func _physics_process(delta):
	# 만약, 현재 Slot에 Weapon이 배정되어 있고, Circular Weapon처럼 update함수가 있다면
	if item != null and item.has_method("update"):
		item.update(delta)

# Slot에 할당된 기본 Weapon은 일정 cooltime마다 activte(공격)된다.
func _on_timer_cooldown_timeout():
	if item:
		$Timer_Cooldown.wait_time = item.cooldown
		item.activate(owner, owner.nearest_enemy, get_tree())
