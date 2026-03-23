extends Area2D

var damage_per_tick: float = 5.0  # урон каждые 0.5 сек
var tick_interval: float = 0.5
var lifetime: float = 3.0         # лужа живёт 3 секунды
var bodies_inside: Array = []     # кто щас в луже
var tick_timer: float = 0.0

func _ready():
	$ColorRect.color = Color(0, 0.8, 0, 0.4)
	
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self): return
	
	$ColorRect.color = Color(0, 1, 0, 0.8)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	await get_tree().create_timer(lifetime).timeout
	if not is_instance_valid(self): return
	queue_free()

func _physics_process(delta):
	if bodies_inside.is_empty(): return
	
	tick_timer -= delta
	if tick_timer <= 0.0:
		tick_timer = tick_interval
		for body in bodies_inside:
			if is_instance_valid(body) and body.has_method("take_damage"):
				body.take_damage(damage_per_tick)
				print("Плющ наносит урон: ", damage_per_tick)

func _on_body_entered(body):
	if body.is_in_group("player"):
		bodies_inside.append(body)

func _on_body_exited(body):
	bodies_inside.erase(body)
