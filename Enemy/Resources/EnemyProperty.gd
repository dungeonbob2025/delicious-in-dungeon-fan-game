extends Resource
class_name EnemyProperty

@export var title:String		# Enemy 이름
@export var texture:Texture2D	# Enemy 텍스처. 추후 AnimatedTexture2D 변경 예정.
@export var health:float		# Enemy 체력
@export var damage:float		# Enemy 공격 데미지
@export var width:float = 64	# Enemy 너비. 특이 몬스터는 64보다 큼.
@export var height:float = 64	# Enemy 높이. 특이 몬스터는 64보다 큼.
@export var drops:Array[Pickups]
