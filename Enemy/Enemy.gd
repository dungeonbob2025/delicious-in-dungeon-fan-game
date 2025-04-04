extends CharacterBody2D

@export var player_reference:CharacterBody2D
var damage_popup_node = preload("res://Equipment Items/Weapon/DamagePopUp.tscn")

## Enemy 속성
# 기본 속성
var direction:Vector2 = Vector2.ZERO
var speed:float = 60
var damage:float
var knockback:Vector2
var separation:float # Player와 Enemy 객체 간 거리를 담는 변수
var health:float:
	set(value):
		health = value
		if health <= 0:
			if is_last_boss:
				#print("Last Boss Died!")
				signal_last_boss_died.emit()
			
			drop_item()
			queue_free()
var elite:bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://Shader/EnemyShader/Elite_Monster_Rainbow_Outline.tres")
			scale = Vector2(1.5, 1.5)
var drop = preload("res://PickUp Items/Pickups.tscn")

# 마지막 보스(레드 드래곤) 몬스터 속성
var is_last_boss:bool = false:
	set(value):
		is_last_boss = value
		if is_last_boss:
			set_collision_shape(is_last_boss)
signal signal_last_boss_died

func set_collision_shape(is_elite_boss:bool):
	if is_elite_boss:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(property.width * 0.8, property.height * 0.8)
		$CollisionShape2D.set_shape(shape)
	else:	
		var shape = CircleShape2D.new()
		shape.radius = 24
		$CollisionShape2D.set_shape(shape)
	
# Resource 정의된 속성 -> 기본 속성 업데이트 등 활용
var property:EnemyProperty:
	set(value):
		property = value
		$Sprite2D.texture = value.texture

		#var shape = RectangleShape2D.new()
		#shape.size = Vector2(value.width, value.height)
		set_collision_shape(is_last_boss)
		damage = value.damage
		health = value.health
	

func _physics_process(delta):
	check_separation(delta)
	knockback_update(delta)

func check_separation(_delta):
	# 만약 Enemy의 위치가 Player로부터 너무 멀리 떨어지면, 스스로 삭제!
	separation = (player_reference.position - position).length()
	if separation >= 800 and not elite:
		queue_free()
		
	if separation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self
		
	if player_reference.position.x - position.x > 0:
		$"Sprite2D".flip_h = true
	else:
		$"Sprite2D".flip_h = false

func knockback_update(delta):
	velocity = (player_reference.position - self.position).normalized() * speed
	knockback = knockback.move_toward(Vector2.ZERO, 1)
	velocity += knockback
	
	var collider = move_and_collide(velocity * delta)
	if collider:
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50

# Enemy가 피격 당하면, amount만큼 PopUp! (몌이플처럼)
func damage_popup(amount):
	var popup = damage_popup_node.instantiate()
	popup.text = str(int(amount * 10))
	popup.position = position + Vector2(-32, -8)
	get_tree().current_scene.add_child(popup)

# Enemy가 데미지 받을 때, 처리하는 함수
# 마르실 공격이라면, Projectile GDScript에서 호출되는 함수!
func take_damage(original_amount):
	# 데미지 범위 랜덤하게 조정
	var min_damage_amount = original_amount * 95
	var max_damage_amount = original_amount * 110
	var amount = randi_range(min_damage_amount, max_damage_amount) / 100.0

	# 피격 시 빨갛게 애니메이션	
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self) # 만약, Enemy가 노드가 queue_free() 되었는데도 애니메이션이 진행되면, Warning 에러가 계속 발생
						  # 노드가 free되면 애니메이션 중단되도록 bind!
	# 데미지 Popup
	damage_popup(amount)
	
	# Enemy 체력 저하
	health -= amount

func drop_item():
	if property.drops.size() == 0:
		return
	var item = property.drops.pick_random() # property의 drops 리스트에 저장된 PickUp Item 목록 중에서 선택
	
	var item_to_drop = drop.instantiate() # PickUp 아이템 정보를 업데이트 (PickUp Item 속성, 현재 Enemy 위치, Player Reference)
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
	
