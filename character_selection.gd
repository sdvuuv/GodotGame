extends Control

@export var characters: Array[CharacterData] = []
var current_index: int = 0

@onready var center_slot = $Carousel/CenterSlot
@onready var left_slot   = $Carousel/LeftSlot
@onready var right_slot  = $Carousel/RightSlot
@onready var name_label  = $UI/NameLabel

func _ready() -> void:
	if characters.size() > 0:
		update_carousel()

func _input(event):
	if event.is_action_pressed("ui_right"):
		current_index = (current_index + 1) % characters.size()
		update_carousel()
	elif event.is_action_pressed("ui_left"):
		current_index = (current_index - 1 + characters.size()) % characters.size()
		update_carousel()
	elif event.is_action_pressed("ui_accept"):  # Enter / Space
		select_character()

func update_carousel():
	var left_index  = (current_index - 1 + characters.size()) % characters.size()
	var right_index = (current_index + 1) % characters.size()

	center_slot.texture = characters[current_index].portrait
	center_slot.modulate = Color(1, 1, 1, 1)

	left_slot.texture  = characters[left_index].portrait
	left_slot.modulate = Color(0.5, 0.5, 0.5, 1)

	right_slot.texture  = characters[right_index].portrait
	right_slot.modulate = Color(0.5, 0.5, 0.5, 1)

	name_label.text = characters[current_index].character_name

func select_character():
	Global.selected_character_id = characters[current_index].id
	Global.load_character_data()
	Global.reset()
	FloorManager.generate_first_floor()
	FloorManager.load_current_room_scene()
