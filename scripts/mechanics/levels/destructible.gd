
extends StaticBody2D
 
# 0 - Колонна (нужна бомба), 1 - Туман (нужен камень очищения)
@export var obstacle_type: int = 0
@export var is_secret: bool = true
 
var pickup_scene = preload("res://scenes/items/pickup.tscn")
 
var player_in_range: bool = false
 
signal interaction_hint_changed(visible: bool, text: String)
 
func _on_interaction_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		interaction_hint_changed.emit(true, _get_hint_text())
 
func _on_interaction_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		interaction_hint_changed.emit(false, "")
 
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		try_destroy()
 
func try_destroy():
	if obstacle_type == 0:
		if Global.bombs > 0:
			Global.bombs -= 1
			interaction_hint_changed.emit(false, "")
			shatter()
		else:
			interaction_hint_changed.emit(true, "Нет взрывных флаконов!")
 
	elif obstacle_type == 1: 
		if Global.cleansers > 0:
			Global.cleansers -= 1
			interaction_hint_changed.emit(false, "")
			shatter()
		else:
			interaction_hint_changed.emit(true, "Нет камней очищения!")
 
func shatter():
	if is_secret:
		var random_stat_item = Global.loot.get_random_stat_item(
			Global.current_character_data.is_melee
		)
		if random_stat_item != null:
			spawn_item(random_stat_item)
	else:
		if randf() < 0.3:
			var random_consumable = Global.loot.get_random_consumable()
			if random_consumable != null:
				spawn_item(random_consumable)
 
	queue_free()
 
func spawn_item(item: ItemData):
	var drop = pickup_scene.instantiate()
	drop.item_data = item
	drop.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", drop)
 
# Возвращает подсказку в зависимости от типа препятствия и наличия ресурсов
func _get_hint_text() -> String:
	if obstacle_type == 0:
		return "E — Взорвать (флаконов: %d)" % Global.bombs
	elif obstacle_type == 1:
		return "E — Рассеять туман (камней: %d)" % Global.cleansers
	return "E — Взаимодействовать"
 
