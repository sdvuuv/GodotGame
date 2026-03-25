extends Node2D
class_name BaseRoom
 
@onready var top_door    = get_node_or_null("TopDoor")
@onready var bottom_door = get_node_or_null("BottomDoor")
@onready var left_door   = get_node_or_null("LeftDoor")
@onready var right_door  = get_node_or_null("RightDoor")
 
var guard_scene      = preload("res://scenes/characters/enemies/guard.tscn")
var golem_scene      = preload("res://scenes/characters/enemies/golem.tscn")
var soul_scene       = preload("res://scenes/characters/enemies/enemy.tscn")
var bomber_scene     = preload("res://scenes/characters/enemies/bomber.tscn")
var ivy_scene        = preload("res://scenes/characters/enemies/ivy.tscn")
var shooter_scene    = preload("res://scenes/characters/enemies/shooter.tscn")
var guard_boss_scene = preload("res://scenes/characters/enemies/booses/guard_boss.tscn")
var troll_boss_scene = preload("res://scenes/characters/enemies/booses/troll_boss.tscn")
 
func _ready() -> void:
	if FloorManager.map_data.is_empty():
		FloorManager.generate_first_floor()
		FloorManager.current_room_pos = Vector2i.ZERO
 
	var pos := FloorManager.current_room_pos
	print("[BaseRoom] _ready, pos=", pos)
 
	_setup_door(top_door,    pos, Vector2i( 0,  1))
	_setup_door(bottom_door, pos, Vector2i( 0, -1))
	_setup_door(left_door,   pos, Vector2i(-1,  0))
	_setup_door(right_door,  pos, Vector2i( 1,  0))
 
	spawn_enemies()
	check_enemies()
 
func _setup_door(door: Node, current_pos: Vector2i, dir: Vector2i) -> void:
	if door == null:
		return
	var neighbor_pos := current_pos + dir
	if not FloorManager.map_data.has(neighbor_pos):
		door.visible = false
		print("[BaseRoom] ", door.name, " скрыта — нет соседа ", neighbor_pos)
		return
	door.direction = Vector2(dir.x, dir.y)
	door.show_door()
	print("[BaseRoom] ", door.name, " direction=", dir, " → сосед ", neighbor_pos)
 
func check_enemies() -> void:
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("[BaseRoom] check_enemies: врагов=", enemies.size())
 
	if enemies.size() == 0:
		if not FloorManager.cleared_rooms.has(FloorManager.current_room_pos):
			FloorManager.cleared_rooms[FloorManager.current_room_pos] = true
		_open_all_available_doors()
	else:
		_lock_all_doors()
 
func _lock_all_doors() -> void:
	for door in [top_door, bottom_door, left_door, right_door]:
		if is_instance_valid(door):
			door.lock_door()
 
func _open_all_available_doors() -> void:
	var pos := FloorManager.current_room_pos
	var door_map := {
		top_door:    pos + Vector2i( 0,  1),
		bottom_door: pos + Vector2i( 0, -1),
		left_door:   pos + Vector2i(-1,  0),
		right_door:  pos + Vector2i( 1,  0),
	}
	for door in door_map:
		if is_instance_valid(door) and FloorManager.map_data.has(door_map[door]):
			door.open_door()
			print("[BaseRoom] ", door.name, " открыта")
 
func spawn_enemies() -> void:
	if FloorManager.cleared_rooms.has(FloorManager.current_room_pos):
		return
	var room_type = FloorManager.map_data[FloorManager.current_room_pos]
	var spawners  = get_tree().get_nodes_in_group("spawn_points")
	if spawners.is_empty():
		return
	match room_type:
		FloorManager.RoomType.BOSS_GUARD:
			_spawn_boss(guard_boss_scene, spawners)
		FloorManager.RoomType.BOSS_TROLL:
			_spawn_boss(troll_boss_scene, spawners)
		FloorManager.RoomType.CITY_PRE_BOSS:
			for sp in spawners:
				_add_enemy(guard_scene.instantiate(), sp.global_position)
		FloorManager.RoomType.SLUM_PRE_BOSS:
			for sp in spawners:
				_add_enemy(
					golem_scene.instantiate() if randf() < 0.5 else ivy_scene.instantiate(),
					sp.global_position
				)
		_:
			for sp in spawners:
				var e = _pick_enemy_for_room(room_type)
				if e:
					_add_enemy(e, sp.global_position)
 
func _pick_enemy_for_room(room_type) -> Node:
	var rt   = FloorManager.RoomType
	var roll = randf()
	match room_type:
		rt.CITY_STREET, rt.CITY_RUINED, rt.CITY_EMPTY_FOG, \
		rt.CITY_GARDEN, rt.CITY_BOTANICAL, rt.CITY_ROYAL_GARDEN:
			if roll < 0.55:   return guard_scene.instantiate()
			elif roll < 0.80: return soul_scene.instantiate()
			else:             return bomber_scene.instantiate()
		rt.SLUM_STREET, rt.SLUM_RUINS, rt.SLUM_EMPTY_FOG, rt.SLUM_FIRE:
			if roll < 0.35:   return golem_scene.instantiate()
			elif roll < 0.70: return shooter_scene.instantiate()
			else:             return ivy_scene.instantiate()
	return null
 
func _spawn_boss(scene: PackedScene, spawners: Array) -> void:
	var boss = scene.instantiate()
	boss.global_position = spawners[0].global_position
	add_child(boss)
 
func _add_enemy(enemy: Node, pos: Vector2) -> void:
	enemy.global_position = pos
	add_child(enemy)
 
