extends Area2D

## Projectile 속성
var direction:Vector2 = Vector2.RIGHT
var speed:float = 300
var damage:float = 10
var source

func _physics_process(delta):
	position += direction * speed * delta

## 최상위 노드인 Area2D(Projectile)의 on_body_entered 시그널
func _on_body_entered(body):
	# body(즉, Enemy)는 유일하게 take_damage 함수를 가지고 있음
	# 따라서, take_damage를 가진 노드가 body_entered되면, damage만큼 데미지 부여
	if body.has_method("take_damage"):
		if "normal_damage" in source and "critical_damage" in source:
			if randf() < 0.3: # 30% 확률로 critical damage (normal damage보다 기본 50% 이상)
				body.take_damage(damage * source.critical_damage * 1.5)
			else: # normal damage
				body.take_damage(damage * source.normal_damage)
		body.knockback = direction * 100
		
		# 관통 시 데미지가 줄어들도록
		damage *= 0.7
		if damage < 1 and is_instance_valid(self):
			queue_free()

## VisibleOnScreenNotifier2D의 screen_exited 시그널
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Arrow가 화면 밖을 넘어가면, Arrow 삭제
	queue_free()
