extends BaseEnemy

var is_jumping: bool = false
var jump_cooldown: bool = false
var aoe_radius: float = 70.0 
@onready var anim = $ColorRect
func _ready():
	super()
	speed = 60.0 

func _physics_process(delta):
	if player == null or is_jumping:
		return
		
	var distance = global_position.distance_to(player.global_position)
	
	if distance < 120.0 and not jump_cooldown:
		perform_jump_aoe()
	else:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func perform_jump_aoe():
	is_jumping = true
	jump_cooldown = true
	
	anim.modulate = Color(1, 0.5, 0)
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self): return

	if player == null: return
	var jump_target = player.global_position
	var tween = create_tween()
	tween.tween_property(self, "global_position", jump_target, 0.3).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	if not is_instance_valid(self): return

	anim.modulate = Color(1, 0, 0)

	if player != null:
		var impact_dist = global_position.distance_to(player.global_position)
		if impact_dist <= aoe_radius:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)
				print("Голем раздавил игрока!")

	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(self): return
	anim.modulate = Color(1, 1, 1)
	is_jumping = false

	await get_tree().create_timer(3.0).timeout
	if not is_instance_valid(self): return
	jump_cooldown = false
