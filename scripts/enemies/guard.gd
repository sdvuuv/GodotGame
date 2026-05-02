extends BaseEnemy

@export var attack_range: float = 45.0
var is_attacking: bool = false
@onready var sword_visual = get_node_or_null("SwordVisual") 
@onready var anim = $ColorRect
func _ready():
	super()
	anim.play("idle")

func _physics_process(delta):
	if player == null or is_dead: return
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	# Отражение спрайта
	anim.flip_h = velocity.x < 0
	if velocity.length() > 5:
		if anim.animation != "hurt" and anim.animation != "attack":
			anim.play("run")

func perform_heavy_attack():
	is_attacking = true
	anim.play("attack")
	anim.modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self): return

	if sword_visual: sword_visual.visible = true

	if player != null and global_position.distance_to(player.global_position) <= attack_range + 10.0:
		player.take_damage(attack_damage)

	await get_tree().create_timer(0.15).timeout
	if not is_instance_valid(self): return
	if sword_visual: sword_visual.visible = false
	anim.modulate = Color(1, 1, 1)
	anim.play("run")
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self): return
	is_attacking = false

func take_damage(amount: float):
	if is_dead: return
	hp -= amount
	anim.play("hurt")
	anim.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(self): return
	anim.modulate = Color(1, 1, 1)
	anim.play("run")
	if hp <= 0:
		is_dead = true
		die()
func die():
	is_dead = true
	anim.play("death")
	set_physics_process(false)
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self): return
	super()
