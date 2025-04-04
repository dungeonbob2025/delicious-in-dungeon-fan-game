extends Pickups
class_name Coin

@export var XP:float

func activate():
	# 부모 클래스 Pickups의 activate 함수 호출
	super.activate()
	#prints("+" + str(XP) + " XP.")
	# Player에게 정의된 gain_XP 함수 호출
	player_reference.gain_XP(XP)
	
