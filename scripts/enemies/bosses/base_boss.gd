extends BaseEnemy
class_name BaseBoss
  
func _ready():
	super() 
 
func take_damage(amount: float):
	if is_dead: return
 
	hp -= amount
 
	if color_rect != null:
		color_rect.modulate = Color(10, 10, 10)
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self): return
		color_rect.modulate = Color(1, 1, 1)
 
	if hp <= 0:
		is_dead = true
		die()
 
func die():
	remove_from_group("enemy")
	var level = get_tree().current_scene
	if level.has_method("check_enemies"):
		level.check_enemies()
	queue_free()
	await get_tree().create_timer(1.5).timeout
	var victory = preload("res://scenes/ui/victory.tscn").instantiate()
	get_tree().current_scene.add_child(victory)
