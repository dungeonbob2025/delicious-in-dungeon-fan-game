extends Node2D

@onready var player_WindowFilter = $"Player/Camera2D/Control/WindowFilter"
@onready var player = $"Player"
@onready var spawner = $"Spawner"
@onready var timer_changestage = $"Timer_ChangeStage"
@onready var background_scenes = [
	preload("res://Stage/Background_BF1.tscn"),
	preload("res://Stage/Background_BF2.tscn"),
	preload("res://Stage/Background_BF3.tscn"),
	preload("res://Stage/Background_BF4.tscn"),
	preload("res://Stage/Background_BF5.tscn")
]

var current_background:ParallaxBackground = null
var changestage_threshold:Array[float] = [540.0, 480.0, 420.0, 360.0, 330.0] # 10초 테스트 : [90.0, 80.0, 70.0, 60.0, 55.0]
var current_stage:int = 1:
	set(value):
		# Spawner 갱신
		current_stage = value
		spawner.current_stage = value
		if current_stage == changestage_threshold.size():
			spawner.spawn_last_boss = true
		
		# Options 값 변경
		%Player/UI/LevelUpOptionsBoard/Panel/Options.current_stage = value
		
		# 배경화면 갱신
		if current_background:
			remove_child(current_background)
			current_background.queue_free()
		current_background = background_scenes[current_stage - 1].instantiate()
		add_child(current_background)

# 배경화면 전환 애니메이션 관련된 Material과 제어 변수들
var background_blurring_material:Material = preload("res://Shader/StageShader/Background_BF1.tres") # 미리 올려두는 Gaussian Blurring Material
var background_window_filter_animation_playing:bool = false # 중복된 Tween 애니메이션 실행 방지를 막아주는 bool 변수
var background_animation_duration:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	current_stage = 1

	# player BlurWinodw 초기화
	player_WindowFilter.material = background_blurring_material
	player_WindowFilter.material.set_shader_parameter("strength", 1.0)
	player_WindowFilter.material.set_shader_parameter("mix_percentage", 0.0)
	
	player.connect_to_spawner(spawner)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	## Background 이미지 변경하면서 Player의 player_WindowFilter.material 수정!
	# Background 이미지 변경 전 페이드인 (background_animation_duration 시간 동안)
	if current_stage < changestage_threshold.size() and timer_changestage.time_left <= changestage_threshold[current_stage - 1] + background_animation_duration and background_window_filter_animation_playing == false:
		animate_blur(1.0, 1.0, 0.0, 1.0, background_animation_duration)
		background_window_filter_animation_playing = true
	# Background 이미지 변경하면서 페이드 아웃 (background_animation_duration 시간 동안)
	if current_stage < changestage_threshold.size() and timer_changestage.time_left <= changestage_threshold[current_stage - 1] and background_window_filter_animation_playing == true:
		current_stage += 1
		animate_blur(1.0, 1.0, 1.0, 0.0, background_animation_duration)
		background_window_filter_animation_playing = false

func animate_blur(strength_from:float, strength_to:float, mix_percentage_from:float, mix_percentage_to:float, duration:float = 2.0):
	# Shader Parameter Value 변경 중 Tween 애니메이션 적용 방법 참고 : https://www.reddit.com/r/godot/comments/u4yy9k/how_to_tween_shader_parameter/
	var tween = get_tree().create_tween().set_parallel(true)
	if strength_from != strength_to:
		tween.tween_method(func(value): player_WindowFilter.material.set_shader_parameter("strength", value), strength_from, strength_to, duration)
	tween.tween_method(func(value): player_WindowFilter.material.set_shader_parameter("mix_percentage", value), mix_percentage_from, mix_percentage_to, duration)
	await tween.finished
