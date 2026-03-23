extends BaseEnemy

var is_exploding: bool = false
@onready var explosion_zone = $ExplosionZone

func _ready():
	super()

func _physics_process(delta):
	if player == null or is_exploding: return
	
	if global_position.distance_to(player.global_position) <= 40.0:
		detonate()
	else:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func detonate():
	is_exploding = true
	for i in range(3):
		color_rect.color = Color(1, 1, 0)
		await get_tree().create_timer(0.15).timeout
		color_rect.color = Color(1, 0, 0)
		await get_tree().create_timer(0.15).timeout
		
	var bodies = explosion_zone.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(attack_damage)
	
	# Он умирает сам, лут обычно не дропает
	die_without_loot()

func die_without_loot():
	remove_from_group("enemy") 
	if get_tree().current_scene.has_method("check_enemies"):
		get_tree().current_scene.check_enemies()
	queue_free()
