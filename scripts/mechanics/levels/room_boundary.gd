@tool
extends StaticBody2D

@export var room_width:     float = 1152.0
@export var room_height:    float = 640.0
@export var wall_thickness: float = 32.0
@export var wall_color:     Color = Color("#2a2535"):
	set(value):
		wall_color = value
		_rebuild()          # ← перестраиваем при изменении
@export var floor_color:    Color = Color("#1c1a24"):
	set(value):
		floor_color = value
		_rebuild()
func _ready() -> void:
		_rebuild()

func _rebuild() -> void:
	# Удаляем старые ноды
	for child in get_children():
		if child is ColorRect or child is CollisionShape2D:
			child.queue_free()
	# Небольшая задержка чтобы queue_free успел отработать
	if Engine.is_editor_hint():
		await get_tree().process_frame
	_build_collision()
	_build_visuals()

func _build_collision() -> void:
	var W  := wall_thickness
	var RW := room_width
	var RH := room_height
	var DW := 128.0  # ширина проёма = ширина двери

	# Верхняя стена — два отрезка с проёмом посередине
	_add_col(Vector2(RW/2 - DW/2 - (RW/2 - DW/2)/2, W/2),
			 Vector2(RW/2 - DW/2, W))
	_add_col(Vector2(RW - (RW/2 - DW/2)/2, W/2),
			 Vector2(RW/2 - DW/2, W))

	# Нижняя стена
	_add_col(Vector2(RW/2 - DW/2 - (RW/2 - DW/2)/2, RH - W/2),
			 Vector2(RW/2 - DW/2, W))
	_add_col(Vector2(RW - (RW/2 - DW/2)/2, RH - W/2),
			 Vector2(RW/2 - DW/2, W))

	# Левая стена — проём посередине по высоте
	_add_col(Vector2(W/2, RH/2 - DW/2 - (RH/2 - DW/2)/2),
			 Vector2(W, RH/2 - DW/2))
	_add_col(Vector2(W/2, RH - (RH/2 - DW/2)/2),
			 Vector2(W, RH/2 - DW/2))

	# Правая стена
	_add_col(Vector2(RW - W/2, RH/2 - DW/2 - (RH/2 - DW/2)/2),
			 Vector2(W, RH/2 - DW/2))
	_add_col(Vector2(RW - W/2, RH - (RH/2 - DW/2)/2),
			 Vector2(W, RH/2 - DW/2))

func _add_col(pos: Vector2, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = pos
	add_child(col)

func _build_visuals() -> void:
	var W  := wall_thickness
	var RW := room_width
	var RH := room_height

	_add_rect(Vector2(0, 0),        Vector2(RW, RH), floor_color)  # пол
	_add_rect(Vector2(0, 0),        Vector2(RW, W),  wall_color)   # верх
	_add_rect(Vector2(0, RH - W),   Vector2(RW, W),  wall_color)   # низ
	_add_rect(Vector2(0, 0),        Vector2(W,  RH), wall_color)   # лево
	_add_rect(Vector2(RW - W, 0),   Vector2(W,  RH), wall_color)   # право

func _add_rect(pos: Vector2, size: Vector2, color: Color) -> void:
	var cr := ColorRect.new()
	cr.position = pos
	cr.size     = size
	cr.color    = color
	add_child(cr)
