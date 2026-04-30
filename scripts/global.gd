extends Node

var loot: LootTable = preload("res://resourсes/items/main_loot.tres")
var selected_character_id: int = 0 
var current_character_data: CharacterData
signal hp_changed(new_hp: float)
signal sanity_changed(new_sanity: float)

var current_hp: float = 100.0 :
	set(value):
		current_hp = value
		hp_changed.emit(current_hp)
var current_sanity: float = 100.0 :
	set(value):
		current_sanity = clampf(value, 0.0, current_character_data.max_sanity if current_character_data else 100.0)
		sanity_changed.emit(current_sanity)
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
		current_sanity = current_character_data.max_sanity  
signal coins_changed(new_coins: int)

var coins: int = 0 :
	set(value):
		coins = value
		coins_changed.emit(coins)
func reset():
	if current_character_data == null:
		return

	current_hp        = current_character_data.max_hp
	bonus_damage      = 0.0
	bonus_speed       = 0.0
	extra_projectiles = 0
	bombs             = 1
	cleansers         = 1
	coins             = 0
