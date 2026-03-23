extends Area2D

@export var direction: Vector2 = Vector2.ZERO 

var is_open: bool = false
@onready var color_rect = $ColorRect

func _ready():
	# По умолчанию дверь заперта (красная)
	color_rect.color = Color(1, 0, 0)

func open_door():
	is_open = true
	color_rect.color = Color(0, 1, 0) # Зеленая

func _on_body_entered(body):
	if is_open and body.is_in_group("player"):
		FloorManager.change_room(direction)
		
		FloorManager.load_current_room_scene()
