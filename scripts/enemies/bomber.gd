extends BaseEnemy

var is_exploding: bool = false
@onready var explosion_zone = $ExplosionZone
@onready var anim = $ColorRect

func _ready():
	super()
	anim.play("idle")


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
	anim.play("death")
	for i in range(3):
		anim.modulate = Color(1, 1, 0)
		await get_tree().create_timer(0.15).timeout
		if not is_instance_valid(self): return
		anim.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.15).timeout
		if not is_instance_valid(self): return

	var bodies = explosion_zone.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(attack_damage)

	die()	

func die():
	is_dead = true
	set_physics_process(false)
	anim.play("death")
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self): return
	super()
