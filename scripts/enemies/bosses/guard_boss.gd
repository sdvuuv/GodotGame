extends BaseBoss
 

var is_attacking: bool = false
 
@onready var aim_pivot = $AimPivot
@onready var sword = $AimPivot/Sword
 
func _ready():
	super() 
	sword.visible = false
 
func _physics_process(_delta):
	if player == null or is_attacking: return
 
	aim_pivot.look_at(player.global_position)
	var dist = global_position.distance_to(player.global_position)
 
	if dist < 70.0:
		spin_attack()
	elif dist < 180.0:
		lunge_attack()
	else:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
 
func spin_attack():
	is_attacking = true
	color_rect.color = Color(1, 0, 1)
 
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self): return
 
	sword.visible = true
	var tween = create_tween()
	tween.tween_property(aim_pivot, "rotation", aim_pivot.rotation + TAU, 0.4)
 
	for i in range(4):
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self): return
		for body in sword.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(attack_damage)
 
	await tween.finished
	sword.visible = false
	color_rect.color = Color(1, 1, 1)
	is_attacking = false
 
func lunge_attack():
	is_attacking = true
 
	for i in range(3):
		color_rect.color = Color(1, 0, 0)
		await get_tree().create_timer(0.15).timeout
		color_rect.color = Color(0, 0, 0.5)
		await get_tree().create_timer(0.15).timeout
	if not is_instance_valid(self): return
 
	sword.visible = true
	var tween = create_tween()
	tween.tween_property(sword, "scale", Vector2(3.0, 1.0), 0.2)
	await tween.finished
	if not is_instance_valid(self): return
 
	for body in sword.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(attack_damage)
 
	var tween_back = create_tween()
	tween_back.tween_property(sword, "scale", Vector2(1.0, 1.0), 0.1)
	await tween_back.finished
	sword.visible = false
 
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self): return
	color_rect.color = Color(1, 1, 1)
	is_attacking = false
