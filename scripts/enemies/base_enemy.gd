extends CharacterBody2D
class_name BaseEnemy # Теперь Godot знает, что это за класс!

@export var hp: float = 20.0
@export var speed: float = 100.0
@export var attack_damage: float = 15.0

var is_dead: bool = false  
var player = null
var pickup_scene = preload("res://scenes/items/pickup.tscn")

@onready var color_rect = $ColorRect

func _ready():
	# Все враги при рождении ищут игрока
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

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
		
	# Дроп предметов (10% шанс)
	if randf() < 0.1: 
		var random_consumable = Global.loot.get_random_consumable()
		if random_consumable != null:
			var drop = pickup_scene.instantiate()
			drop.item_data = random_consumable
			drop.global_position = global_position 
			get_tree().current_scene.call_deferred("add_child", drop)
			
	queue_free()
