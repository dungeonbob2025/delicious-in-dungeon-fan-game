extends Resource
class_name Stats # Weapon Upgrades에 대응

@export_multiline var description:String

#@export var health_stats:float			# 체력 회복 -> PickUp 아이템으로 대체?
@export var XP_growth_stats:float		# 경험치 획등량 증가
@export var normal_damage_stats:float	# 공격력 데미지 증가
@export var critical_damage_stats:float # 크리티컬 데미지 증가
@export var speed_stats:float			# 이동속도 증가
@export var area_stats:float			# 공격 범위 증가
@export var magnet_stats:float			# Coin 수집 범위 증가
