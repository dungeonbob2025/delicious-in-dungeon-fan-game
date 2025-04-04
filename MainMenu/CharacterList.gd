extends GridContainer

@onready var starting_weapon = %StartingWeapon
@onready var character_title = %Label_CharacterTitle
@onready var character_description = %Label_CharacterDescription
@onready var click_sound:AudioStream = preload("res://Asset/5. Audio/button_click.mp3")
@export var character_slot:PackedScene
var character_resource_path: String = "res://Player/Resources/"  # 캐릭터 .tres 파일들이 있는 폴더 경로
var characters:Array[Character]

# Called when the node enters the scene tree for the first time.
func _ready():
	Persistence.character = null
	load_characters()

# 매번 캐릭터 정보를 로드해서, 앞선 게임 판에서 수정된 character Resource 정보를 다시 초기화
# (e.g. amount, damage 등등)
# 비효율적이지만, 캐릭터 수가 많지 않으므로 현재 시점에선 적당한 해결책..
func load_characters():
	characters = load_character_resources(character_resource_path)
	for character in characters:
		var slot = character_slot.instantiate()
		slot.icon = character.character_icon
		slot.pressed.connect(_on_pressed.bind(character))
		add_child(slot)

func _on_pressed(character:Character):
	SoundManager.play_sfx(click_sound)
	Persistence.character = character.duplicate()
	starting_weapon.texture = character.starting_weapon.texture
	character_title.text = character.character_title
	character_description.text = character.character_description

func load_character_resources(path: String) -> Array[Character]:
	var dir = DirAccess.open(path)
	var character_resources: Array[Character] = []

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if OS.has_feature("editor"):
				if file_name.ends_with(".tres"):
					var full_path = path.path_join(file_name)
					var character_resource: Character = load(full_path)
					if character_resource is Character:
						character_resources.append(character_resource)
			else:
				if file_name.ends_with(".remap"):
					file_name = file_name.replace(".remap", "")
					var full_path = path.path_join(file_name)
					var character_resource: Character = load(full_path)
					if character_resource is Character:
						character_resources.append(character_resource)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path: " + path)
	
	return character_resources
