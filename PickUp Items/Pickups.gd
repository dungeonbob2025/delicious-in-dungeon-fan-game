extends Area2D

var direction:Vector2
var speed:float = 300

@export var type:Pickups # Coin 등 Resource에서 정의된 Pickups 아이템 종류
@export var player_reference:CharacterBody2D:
	set(value):
		player_reference = value
		type.player_reference = value

# Player의 Magent 범위에 들어와야만 can_follow할 수 있음
var can_follow:bool = false

func _ready():
	$Sprite2D.texture = type.icon
	
func _physics_process(delta):
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta

func follow(_target:CharacterBody2D):
	can_follow = true

# Pickups(Area2D) 노드의 body_entered 시그널
# Player에게 끌려가고, 최종적으로 Player에 닿게 되면 호출되는 시그널!
func _on_body_entered(body):
	type.activate()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
