extends Node2D

@onready var top_door = get_node_or_null("TopDoor")
@onready var bottom_door = get_node_or_null("BottomDoor")

var guard_scene      = preload("res://scenes/characters/enemies/guard.tscn")
var golem_scene      = preload("res://scenes/characters/enemies/golem.tscn")
var soul_scene       = preload("res://scenes/characters/enemies/enemy.tscn")
var bomber_scene     = preload("res://scenes/characters/enemies/bomber.tscn")
var ivy_scene        = preload("res://scenes/characters/enemies/ivy.tscn")
var shooter_scene    = preload("res://scenes/characters/enemies/shooter.tscn")
var guard_boss_scene = preload("res://scenes/characters/enemies/booses/guard_boss.tscn")
var troll_boss_scene = preload("res://scenes/characters/enemies/booses/troll_boss.tscn")

func _ready():
	var current_pos = FloorManager.current_room_pos

	if not FloorManager.map_data.has(current_pos + Vector2(0, 1)) and top_door != null:
		top_door.queue_free()
	if not FloorManager.map_data.has(current_pos + Vector2(0, -1)) and bottom_door != null:
		bottom_door.queue_free()

	spawn_enemies()
	check_enemies()

func check_enemies():
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemy")

	if enemies.size() == 0:
		if not FloorManager.cleared_rooms.has(FloorManager.current_room_pos):
			FloorManager.cleared_rooms[FloorManager.current_room_pos] = true

		if is_instance_valid(top_door):
			top_door.open_door()
		if is_instance_valid(bottom_door):
			bottom_door.open_door()

func spawn_enemies():
	if FloorManager.cleared_rooms.has(FloorManager.current_room_pos):
		return

	var room_type = FloorManager.map_data[FloorManager.current_room_pos]
	var spawners = get_tree().get_nodes_in_group("spawn_points")

	if room_type == "Boss_GuardOfficer" or room_type == "Boss_Troll":
		var boss_scene = guard_boss_scene if room_type == "Boss_GuardOfficer" else troll_boss_scene
		var boss = boss_scene.instantiate()
		boss.global_position = spawners[0].global_position
		add_child(boss)
		return

	for spawner in spawners:
		var enemy_instance = _pick_enemy_for_room(room_type)
		if enemy_instance != null:
			enemy_instance.global_position = spawner.global_position
			add_child(enemy_instance)

func _pick_enemy_for_room(room_type: String) -> Node:
	var roll = randf()
	match room_type:
		"City_Street":
			if roll < 0.5:  return guard_scene.instantiate()
			elif roll < 0.8: return soul_scene.instantiate()
			else:            return bomber_scene.instantiate()
		"Slums_Street":
			if roll < 0.3:  return golem_scene.instantiate()
			elif roll < 0.7: return shooter_scene.instantiate()
			else:            return ivy_scene.instantiate()
	return null
