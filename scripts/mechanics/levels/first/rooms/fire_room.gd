extends BaseRoom

var fire_puddle_scene = preload("res://scenes/mechanics/toxic_puddle.tscn")

func _ready() -> void:
	super()
	_spawn_fire_puddles()

func _spawn_fire_puddles() -> void:
	var positions = [
		Vector2(300, 280),
		Vector2(700, 360),
		Vector2(500, 450),
	]
	for pos in positions:
		var puddle = fire_puddle_scene.instantiate()
		puddle.global_position = pos
		# Перекрашиваем в огненный цвет
		puddle.modulate = Color("#ff6a00")
		add_child(puddle)
