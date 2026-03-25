extends BaseRoom

@onready var control_hints = $UILayer/ControlHints
@onready var npc_area      = $SomeGuy/Area2D
@onready var dialog_label  = $UILayer/ControlHints
@onready var npc_zone = $NPCZone
func _ready() -> void:
	super()
	top_door.open_door()
	bottom_door.open_door()

	npc_area.show_text.connect(_on_show_dialogue)
	npc_area.hide_text.connect(_on_hide_dialogue)

func _on_show_dialogue(text: String) -> void:
	control_hints.text = text
	control_hints.modulate = Color("#e0d0ff")

func _on_hide_dialogue(_dummy = null) -> void:
	control_hints.text = "WASD — движение\nСтрелки — атака\nE — взаимодействие"
	control_hints.modulate = Color("#8a7aaa")
