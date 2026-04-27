extends Control
@export var characters: Array[CharacterData] = []
var current_index: int = 0

@onready var center_slot = $Carousel/CenterSlot
@onready var left_slot = $Carousel/LeftSlot
@onready var right_slot = $Carousel/RightSlot

@onready var name_label = $UI/NameLabel
@onready var desc_label = $UI/DescLabel

func _ready() -> void:
	if characters.size() > 0:
		update_carousel()
func update_carousel():
	# Если current_index = 0, то left_index станет 3 (четвертый персонаж)
	var left_index = (current_index - 1 + characters.size()) % characters.size()
	var right_index = (current_index + 1) % characters.size()
	
	center_slot.color = characters[current_index].placeholder_color
	left_slot.color = characters[left_index].placeholder_color
	right_slot.color = characters[right_index].placeholder_color
	
	name_label.text = characters[current_index].character_name
	desc_label.text = characters[current_index].description


func _on_select_button_pressed():
	Global.selected_character_id = characters[current_index].id
	Global.load_character_data()
	Global.reset()
	FloorManager.generate_first_floor()
	FloorManager.load_current_room_scene()

func _on_right_button_pressed() -> void:
	current_index = (current_index + 1) % characters.size()
	update_carousel()

func _on_left_button_pressed() -> void:
	current_index = (current_index - 1 + characters.size()) % characters.size()
	update_carousel()
