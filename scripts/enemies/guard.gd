extends BaseEnemy

@export var attack_range: float = 45.0
var is_attacking: bool = false
@onready var sword_visual = get_node_or_null("SwordVisual") 

func _ready():
	super() 

func _physics_process(delta):
	if player == null or is_attacking: return
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		perform_heavy_attack()
	else:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func perform_heavy_attack():
	is_attacking = true
	color_rect.color = Color(1, 0, 0)
	await get_tree().create_timer(0.4).timeout
	
	if sword_visual: sword_visual.visible = true
	
	if player != null and global_position.distance_to(player.global_position) <= attack_range + 10.0:
		player.take_damage(attack_damage)
			
	await get_tree().create_timer(0.15).timeout
	if sword_visual: sword_visual.visible = false
	color_rect.color = Color(0, 0, 1) 
	await get_tree().create_timer(1.0).timeout 
	is_attacking = false
