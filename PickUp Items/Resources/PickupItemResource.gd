extends Resource
class_name Pickups

@export var title:String
@export var icon:Texture2D
@export_multiline var description:String
@export var sound:AudioStream

var player_reference:CharacterBody2D

# Pickup 아이템이 습득되었을 때 호출되는 함수 (이후 아이템마다 오버라이딩)
func activate():
	SoundManager.play_sfx(sound)
	#print(title + " picked up.")
	#pass
