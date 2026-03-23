extends Node

var loot: LootTable = preload("res://resourсes/items/main_loot.tres")
var selected_character_id: int = 0 
var current_character_data: CharacterData
signal hp_changed(new_hp: float)

var current_hp: float = 100.0 :
	set(value):
		current_hp = value
		hp_changed.emit(current_hp)
var bombs: int = 1 # Взрывные флаконы 
var cleansers: int = 1 # Камни очищения
var bonus_damage: float = 0.0
var bonus_speed: float = 0.0
var extra_projectiles: int = 0
func load_character_data():
	var path = "res://resourсes/char%d.tres" % selected_character_id
	current_character_data = load(path)
	if current_character_data != null:
		current_hp = current_character_data.max_hp
