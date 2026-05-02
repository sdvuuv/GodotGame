extends Area2D

@export var direction: Vector2 = Vector2.ZERO

var is_open: bool = false
@onready var color_rect = $ColorRect
@onready var blocker = $Blocker  # StaticBody2D — стена когда дверь закрыта

func _ready():
	visible = false
	blocker.visible = false
	_set_blocker(true)  # коллизия включена по умолчанию

func show_door() -> void:
	visible = true
	is_open = false
	color_rect.modulate = Color(1, 0.3, 0.3)  # красноватый — закрыта
	_set_blocker(true)

func lock_door() -> void:
	is_open = false
	color_rect.modulate = Color(1, 0.3, 0.3)
	_set_blocker(true)


func open_door() -> void:
	is_open = true
	visible = true
	color_rect.modulate = Color(1, 1, 1)  # нормальный цвет — открыта
	_set_blocker(false)

func _set_blocker(enabled: bool) -> void:
	blocker.visible = enabled
	# Включаем/выключаем коллизию блокера
	for child in blocker.get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled

func _on_body_entered(body: Node2D) -> void:
	if is_open and body.is_in_group("player"):
		FloorManager.change_room(Vector2i(int(direction.x), int(direction.y)))
