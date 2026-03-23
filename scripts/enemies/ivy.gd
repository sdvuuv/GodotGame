extends BaseEnemy

var puddle_scene = preload("res://scenes/mechanics/toxic_puddle.tscn")
@onready var shoot_timer = $ShootTimer

func _ready():
	super()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _on_shoot_timer_timeout():
	if player == null: return
	
	color_rect.color = Color(1, 1, 1)
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(self): return
	
	color_rect.color = Color(0, 0.5, 0)
	
	var puddle = puddle_scene.instantiate()
	puddle.global_position = player.global_position
	get_tree().current_scene.add_child(puddle)
