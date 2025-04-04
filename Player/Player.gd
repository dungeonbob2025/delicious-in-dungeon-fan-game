extends CharacterBody2D

@onready var animatedsprite2d:AnimatedSprite2D = $"AnimatedSprite2D"
@export var character:Character

@export var option_sound:AudioStream
@export var win_sound:AudioStream
@export var die_sound:AudioStream

## Player 속성 변수 (일부 변수는 Stats에서 관리됨)
var speed:float = 150
var health:float = 500:
	set(value):
		health = min(max(value, 0), max_health)
		%HealthProgressBar.value = value
		
		if health == 0:
			SoundManager.play_sfx(die_sound)
			%Options.close_option()
			%Panel_GameClear.hide()
			%Panel_GameOver.show()
			get_tree().paused = true
		
var max_health:float = 500:
	set(value):
		max_health = value
		%HealthProgressBar.max_value = value
var normal_damage:float = 1.0
var critical_damage:float = 1.0
var area:float = 0.0
var magnet:float = 0.0:
	set(value):
		magnet = value
		%CollisionShape2D_Magnet.shape.radius = value
var XP_growth:float = 1.0

# 플레이어로부터 가장 가까운 적을 찾는 변수
# 마르실 공격을 사용할 때 사용
var nearest_enemy:CharacterBody2D
var nearest_enemy_distance:float = 200 + area

## 기존에 계획했던 XP와 Player Level 변수
#var XP_per_level = [20, 30, 50, 70, 100, 130, 170, 210, 260, # 1 -> 10
					#320, 390, 470, 560, 660, 770, 890, 1020, 1160, 1310, # 11 -> 20
					#1470, 1640, 1820, 2010, 2210, 2420, 2640, 2870, 3110, 3360 # 21 -> 30
					#]
# 수정한 XP와 Player Level 변수 : 생각보다 어려워서, XP 요구량 완화
# 10, 15, 20, ... 50, 10, 15, ... 이렇게 증가
var XP_per_level = [20, 30, 40, 50, 60, 70, 80, 90, 100, 
					130, 160, 190, 220, 250, 280, 310, 340, 370, 400, 
					460, 520, 580, 640, 700, 760, 820, 880, 940, 1000,
					]
var max_level:int = 30
var XP:int = 0:
	set(value):
		XP = value
		%ProgressBar_XP.value = value
var total_XP:int = 0
var level:int = 1:
	set(value):
		level = value
		%Level.text = "Level " + str(value)
		health += (max_health * 0.2) # 레벨업 시 최대 체력의 20% 회복
		
		SoundManager.play_sfx(option_sound)
		%Options.show_option() # 레벨업하면, 옵션 보여주기!
		if level < max_level:
			%ProgressBar_XP.max_value = XP_per_level[level - 1]

## Player 애니메이션 제어 변수
var is_running = false

func _ready():
	max_health = 400
	health = max_health
	magnet = 128
	character = Persistence.character
	character.starting_weapon.level = 1
	%Options.check_item(character.starting_weapon)

func connect_to_spawner(spawner):
	#var spawner = get_node("res://Enemy/Spawner.tscn")
	#var timer = spawner.get_node("Timer_NormalSpawn")
	#timer.finished.connect(timer_finished)
	spawner.finished.connect(timer_finished)

func timer_finished():
	if health > 0:
		SoundManager.play_sfx(die_sound)
		%Options.close_option()
		%Panel_GameClear.hide()
		%Panel_GameOver.show()
		get_tree().paused = true

func _physics_process(delta):
	if is_instance_valid(nearest_enemy): # Enemy가 죽어서 free되면, 이미 사라진 노드를 확인하게 되므로.. 에러 발생!
		nearest_enemy_distance = nearest_enemy.separation
		#print(nearest_enemy.name)
	else:
		nearest_enemy_distance = 200 + area
		nearest_enemy = null

	velocity = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN") * speed
	is_running = true if velocity != Vector2.ZERO else false
	
	move_and_collide(velocity * delta)
	check_XP()

	# 애니메이션 처리
	if is_running == true:
		animatedsprite2d.play("Player_Running")
	else:
		animatedsprite2d.play("Player_Idle")
	if velocity.x > 0:
		animatedsprite2d.flip_h = true
	else:
		animatedsprite2d.flip_h = false
		

func take_damage(damage_amount:float):
	health -= damage_amount
	#print(health, " ", damage_amount)

# SelfDamageHitBox 시그널 처리
# body는 Enemy(CharacterBody2D)
func _on_self_damage_hit_box_body_entered(body):
	take_damage(body.damage)

# Timer_HitBoxRenew 시그널 처리
func _on_timer_hit_box_renew_timeout():
	# Enemy가 Player 위에 겹칠 때, 계속 body_entered 확인할 수 있도록 갱신
	%HitBoxCollision.set_deferred("disabled", true)
	%HitBoxCollision.set_deferred("disabled", false)

# Pickup 아이템을 습득했을 때, XP 얻는 처리하는 함수
# Resource 디렉토리에 있는 Coin GDScript에서 호출될 예정
func gain_XP(amount):
	if level < max_level:
		XP += amount * XP_growth
		total_XP += amount * XP_growth

func check_XP():
	if XP > %ProgressBar_XP.max_value and level < max_level:
		XP -= %ProgressBar_XP.max_value
		level += 1

# Magnet 노드와 연결된 시그널
# Pickup 아이템(area)이 Magnet 노드 범위에 들어오면, 호출!
func _on_magnet_area_entered(area):
	if area.has_method("follow"):
		area.follow(self)

func last_boss_died():
	SoundManager.play_sfx(win_sound)
	%Options.close_option()
	%Panel_GameOver.hide()
	%Panel_GameClear.show()
	get_tree().paused = true
