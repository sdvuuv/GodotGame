extends BaseBoss
 
 
var is_casting: bool = false
 
var projectile_scene = preload("res://scenes/mechanics/enemy_projectile.tscn")
var puddle_scene     = preload("res://scenes/mechanics/toxic_puddle.tscn")
 
func _ready():
	super() 
	attack_loop()
 
func _physics_process(_delta):
	if player == null or is_casting: return
 
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
 
func attack_loop():
	while is_instance_valid(self) and hp > 0:
		await get_tree().create_timer(2.0).timeout
		if not is_instance_valid(self): return
		if player == null: break
 
		is_casting = true
		color_rect.color = Color(1, 1, 0) # Желтеет — готовится к касту
		await get_tree().create_timer(1.0).timeout
		if not is_instance_valid(self): return
 
		color_rect.color = Color(0.2, 0.4, 0.2)
 
		if randf() > 0.5:
			cast_nova()
		else:
			cast_puddles()
 
		await get_tree().create_timer(1.0).timeout
		if not is_instance_valid(self): return
		is_casting = false
 
func cast_nova():
	var bullet_count = 12
	var angle_step = deg_to_rad(360.0 / bullet_count)
 
	for i in range(bullet_count):
		var proj = projectile_scene.instantiate()
		proj.direction = Vector2.RIGHT.rotated(i * angle_step)
		proj.global_position = global_position
		proj.speed = 150.0
		proj.damage = attack_damage 
		get_tree().current_scene.add_child(proj)
 
func cast_puddles():
	for i in range(3):
		var puddle = puddle_scene.instantiate()
		var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
		puddle.global_position = player.global_position + offset
		get_tree().current_scene.add_child(puddle)
 
