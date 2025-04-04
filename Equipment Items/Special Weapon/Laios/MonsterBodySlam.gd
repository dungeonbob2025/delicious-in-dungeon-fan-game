extends Area2D

var damage:float = 50
var source

# 최상위 노드인 Area2D(Explosion)의 on_body_entered 시그널
func _on_body_entered(body):
	# body(즉, Enemy)는 유일하게 take_damage 함수를 가지고 있음
	# 따라서, take_damage를 가진 노드가 body_entered되면, damage만큼 데미지 부여
	if body.has_method("take_damage"):
		if "normal_damage" in source and "critical_damage" in source:
			# 무조건 Critical 데미지 (2배)
			body.take_damage(damage * source.critical_damage * 2)
		
		# TODO: 흠.. 넉백이 계속 버그가 생기네..
		#body.knockback = (body.position - position).normalized() * 75

## 생성 후 시간이 지나면 자동으로 사라지기
func _on_timer_timeout():
	queue_free()

