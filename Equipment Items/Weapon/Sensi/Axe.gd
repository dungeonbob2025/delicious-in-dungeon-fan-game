extends Weapon
class_name Axe

@export var radius = 128	# 공격 반경
var slash_area_reference	# Slash Area 참조를 위한 변수
var current_direction = Vector2.RIGHT # 현재 공격 방향

func reset():
	if is_instance_valid(slash_area_reference):
		slash_area_reference.queue_free()

# 상위 Weapon 클래스에서 받은 추상 메소드
func activate(source, _target, _scene_tree):
	reset_collision()
	if not slash_area_reference:
		add_to_player(source)

# add_to_player를 통해 SlashArea 생성
func add_to_player(source):
	var slash_area = sensi_projectile_node.instantiate()

	slash_area.position = Vector2.RIGHT * radius / 2
	slash_area.radius = radius
	slash_area.damage = damage
	slash_area.source = source
	
	slash_area_reference = slash_area
	slash_area_reference.hide()
	slash_area_reference.find_child("CollisionShape2D").disabled = true
	source.call_deferred("add_child", slash_area_reference)

func update(_delta):
	if slash_area_reference:
		if slash_area_reference.source.velocity.x < 0:
			current_direction = Vector2.LEFT
			slash_area_reference.find_child("AnimatedSprite2D").flip_h = true
		elif slash_area_reference.source.velocity.x > 0:
			current_direction = Vector2.RIGHT
			slash_area_reference.find_child("AnimatedSprite2D").flip_h = false
		
		slash_area_reference.position = current_direction * radius / 2

func reset_collision():
	if slash_area_reference:
		slash_area_reference.show()
		slash_area_reference.find_child("CollisionShape2D").disabled = false
		slash_area_reference.get_children()
		await slash_area_reference.get_tree().create_timer(0.5).timeout
		slash_area_reference.find_child("CollisionShape2D").disabled = true
		slash_area_reference.hide()
		

func upgrade_item():
	if not is_upgradable():
		return

	if level == 0:
		level += 1
		return
		
	var upgrade = upgrades[level]
	slash_area_reference.radius *= upgrade.radius
	slash_area_reference.damage *= upgrade.damage
	cooldown *= upgrade.cooldown
	
	level += 1
