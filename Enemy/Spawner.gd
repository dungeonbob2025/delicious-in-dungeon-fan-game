extends Node2D

@export var player:CharacterBody2D
@export var enemy:PackedScene
## 조금 무식하지만 간편하게 스테이지 별 enemy_properties 설정
## Godot 엔진에서 2D Array 만들기 좀 복잡하네...
@export var enemy_properties_BF1:Array[EnemyProperty] # 스테이지 1
@export var enemy_properties_BF2:Array[EnemyProperty] # 스테이지 2
@export var enemy_properties_BF3:Array[EnemyProperty] # 스테이지 3
@export var enemy_properties_BF4:Array[EnemyProperty] # 스테이지 4
@export var enemy_properties_BF5:Array[EnemyProperty] # 스테이지 5, 6(레드 드래곤)

## 기본 변수
var current_stage:int = 1 # 현재 스테이지
var spawn_last_boss:bool = false # 마지막 6번째 스테이지에서 1번만 엘리트 몬스터(레드 드래곤) 스폰

## Enemy 생성 위치 설정
var distance:float = 400 # Player부터 400 떨어진 위치에서 생성
var can_spawn:bool = true

## UI_CountDown 설정 변수
# Game TimeOut 시그널
signal finished
var minute:int = 10:
	set(value):
		minute = value
		%UI_CountDown_Minute.text = str(value).lpad(2,'0')
var second:int = 0:
	set(value):
		second = value
		if second < 0:
			second = 59 # 10초 단위 카운트다운, 실제 게임에선 60초 단위 카운트 다운. 따라서 59.
			minute -= 1
			if minute < 0:
				minute = 0
				second = 0
				# Game Timeout 시그널 방출 & 더이상 처리할 필요 없음
				finished.emit()

		%UI_CountDown_Second.text = str(second).lpad(2,'0')

func _physics_process(_delta):
	if get_tree().get_nodes_in_group("Enemy").size() > 300:
		can_spawn = false
	else:
		can_spawn = true

func get_enemy_properties(value:int):
	if value == 1:
		return enemy_properties_BF1
	elif value == 2:
		return enemy_properties_BF2
	elif value == 3:
		return enemy_properties_BF3
	elif value == 4:
		return enemy_properties_BF4
	elif value >= 5:
		return enemy_properties_BF5
	else:
		return enemy_properties_BF5

func spawn(pos:Vector2, elite:bool = false):
	var enemy_instance = enemy.instantiate()

	# 튜토리얼의 type에 대응
	var current_enemy_properties = get_enemy_properties(current_stage)

	if current_stage < 3: # BF1, BF2
		var random_choice:int = randi() % current_enemy_properties.size()
		enemy_instance.property = current_enemy_properties[random_choice]
	elif current_stage == 3:
		if elite:
			# 마지막 BF3 엘리트 몬스터 2마리
			var random_choice:int = current_enemy_properties.size() - 1 - (randi() % 2)
			enemy_instance.property = current_enemy_properties[random_choice]
		else:
			# BF3 엘리트 몬스터 2마리 제외
			var random_choice:int = randi() % (current_enemy_properties.size() - 2)
			enemy_instance.property = current_enemy_properties[random_choice]
	elif current_stage == 4:
		if elite:
			# 마지막 BF4 엘리트 몬스터 1마리
			var random_choice:int = current_enemy_properties.size() - 1
			enemy_instance.property = current_enemy_properties[random_choice]
		else:		
			# BF4 엘리트 몬스터 1마리 제외
			var random_choice:int = randi() % (current_enemy_properties.size() - 1)
			enemy_instance.property = current_enemy_properties[random_choice]
	else: # BF5
		if elite and spawn_last_boss:
			# 마지막 BF5 엘리트 몬스터(레드 드래곤) 1마리
			var random_choice:int = current_enemy_properties.size() - 1
			enemy_instance.property = current_enemy_properties[random_choice]
			enemy_instance.is_last_boss = true
			enemy_instance.signal_last_boss_died.connect(player.last_boss_died.bind())
			spawn_last_boss = false
		else:
			# BF5 엘리트 몬스터(레드 드래곤) 1마리 제외
			var random_choice:int = randi() % (current_enemy_properties.size() - 1)
			enemy_instance.property = current_enemy_properties[random_choice]

	# 엘리트 몬스터들은 일반 몬스터들을 통과할 수 있도록 collision layer와 mask 설정	
	if elite:
		enemy_instance.set_collision_layer_value(2, false)
		enemy_instance.set_collision_mask_value(2, false)
		enemy_instance.set_collision_layer_value(3, true)
		enemy_instance.set_collision_mask_value(3, true)
		
		# 엘리트 몬스터 속도 2배
		enemy_instance.speed *= 2
		# Collision 모양은 Rectangle으로 재지정
		enemy_instance.set_collision_shape(elite)
		
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	
	get_tree().current_scene.add_child(enemy_instance)

func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

func amount(number:int = 1):
	for i in range(number):
		spawn(get_random_position())

# Timer_NormalSpawn 시그널
func _on_timer_normal_spawn_timeout():
	second -= 1
	if can_spawn:
		amount(second % 10)

# Timer_PatternNormalSpawn 시그널
func _on_timer_pattern_normal_spawn_timeout():
	if can_spawn:
		for i in range(32):
			spawn(get_random_position())

# Timer_EliteSpawn 시그널
func _on_timer_elite_spawn_timeout():
	if current_stage >= 3:
		spawn(get_random_position(), true)
