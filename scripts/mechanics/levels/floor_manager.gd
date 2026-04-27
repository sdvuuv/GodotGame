extends Node

# ─────────────────────────────────────────────────────────────
#  Типы комнат
# ─────────────────────────────────────────────────────────────
enum RoomType {
	START,

	# Городские (верхняя ветка, Y > 0)
	CITY_STREET,
	CITY_GARDEN,
	CITY_BOTANICAL,
	CITY_RUINED,
	CITY_EMPTY_FOG,
	CITY_ROYAL_GARDEN,
	CITY_TEMPLE,
	CITY_SHOP,
	CITY_PRE_BOSS,

	# Трущобы/лес (нижняя ветка, Y < 0)
	SLUM_STREET,
	SLUM_RUINS,
	SLUM_EMPTY_FOG,
	SLUM_SHOP,
	SLUM_FIRE,
	SLUM_PRE_BOSS,

	# Боссы
	BOSS_GUARD,
	BOSS_TROLL,
}

# ─────────────────────────────────────────────────────────────
#  Сцены
# ─────────────────────────────────────────────────────────────
const ROOM_SCENES: Dictionary = {
	RoomType.START:             "res://scenes/levels/first/rooms/start_room.tscn",

	RoomType.CITY_STREET:       "res://scenes/levels/first/rooms/city_street.tscn",
	RoomType.CITY_GARDEN:       "res://scenes/levels/first/rooms/city_garden.tscn",
	RoomType.CITY_BOTANICAL:    "res://scenes/levels/first/rooms/city_botanical.tscn",
	RoomType.CITY_RUINED:       "res://scenes/levels/first/rooms/city_ruined.tscn",
	RoomType.CITY_EMPTY_FOG:    "res://scenes/levels/first/rooms/city_empty_fog.tscn",
	RoomType.CITY_ROYAL_GARDEN: "res://scenes/levels/first/rooms/city_royal_garden.tscn",
	RoomType.CITY_TEMPLE:       "res://scenes/levels/first/rooms/city_temple.tscn",
	RoomType.CITY_SHOP:         "res://scenes/levels/first/rooms/city_shop.tscn",
	RoomType.CITY_PRE_BOSS:     "res://scenes/levels/first/rooms/city_street.tscn",

	RoomType.SLUM_STREET:       "res://scenes/levels/first/rooms/slum_street.tscn",
	RoomType.SLUM_RUINS:        "res://scenes/levels/first/rooms/slum_ruins.tscn",
	RoomType.SLUM_EMPTY_FOG:    "res://scenes/levels/first/rooms/slum_empty_fog.tscn",
	RoomType.SLUM_SHOP:         "res://scenes/levels/first/rooms/slum_shop.tscn",
	RoomType.SLUM_FIRE:         "res://scenes/levels/first/rooms/slum_fire.tscn",
	RoomType.SLUM_PRE_BOSS:     "res://scenes/levels/first/rooms/slum_pre_boss.tscn",

	RoomType.BOSS_GUARD:        "res://scenes/levels/first/boss_rooms/guard_boss_room.tscn",
	RoomType.BOSS_TROLL:        "res://scenes/levels/first/boss_rooms/troll_boss_room.tscn",
}

# ─────────────────────────────────────────────────────────────
#  Пулы с весами: [RoomType, вес]
# ─────────────────────────────────────────────────────────────
const CITY_MAIN_POOL: Array = [
	[RoomType.CITY_STREET,       50],
	[RoomType.CITY_RUINED,       20],
	[RoomType.CITY_EMPTY_FOG,    12],
	[RoomType.CITY_BOTANICAL,     8],
	[RoomType.CITY_ROYAL_GARDEN,  3],
]
const CITY_SIDE_LEFT_POOL: Array = [
	[RoomType.CITY_SHOP,    60],
	[RoomType.CITY_GARDEN,  40],
]
const CITY_SIDE_RIGHT_POOL: Array = [
	[RoomType.CITY_TEMPLE,     55],
	[RoomType.CITY_EMPTY_FOG,  45],
]

const SLUM_MAIN_POOL: Array = [
	[RoomType.SLUM_STREET,    45],
	[RoomType.SLUM_RUINS,     30],
	[RoomType.SLUM_EMPTY_FOG, 25],
]
const SLUM_SIDE_LEFT_POOL: Array = [
	[RoomType.SLUM_SHOP,  60],
	[RoomType.SLUM_RUINS, 40],
]
const SLUM_SIDE_RIGHT_POOL: Array = [
	[RoomType.SLUM_FIRE,       50],
	[RoomType.SLUM_EMPTY_FOG,  50],
]

# ─────────────────────────────────────────────────────────────
#  Состояние
# ─────────────────────────────────────────────────────────────
var map_data:      Dictionary = {}   # Vector2i → RoomType
var cleared_rooms: Dictionary = {}   # комнаты без врагов
var visited_rooms: Dictionary = {}   # комнаты, в которых игрок уже был
var current_room_pos: Vector2i = Vector2i.ZERO

var _city_garden_placed: bool = false
var _slum_fire_placed:   bool = false

# ─────────────────────────────────────────────────────────────
#  Публичный API
# ─────────────────────────────────────────────────────────────
func generate_first_floor() -> void:
	map_data.clear()
	cleared_rooms.clear()
	visited_rooms.clear()
	_city_garden_placed = false
	_slum_fire_placed   = false
	current_room_pos    = Vector2i.ZERO

	map_data[Vector2i.ZERO] = RoomType.START
	visited_rooms[Vector2i.ZERO] = true   # стартовая комната сразу посещена

	var up_len   = randi_range(3, 5)
	var down_len = randi_range(3, 5)

	_build_branch(
		Vector2i(0,  1), up_len,
		CITY_MAIN_POOL, CITY_SIDE_LEFT_POOL, CITY_SIDE_RIGHT_POOL,
		RoomType.CITY_PRE_BOSS, RoomType.BOSS_GUARD, true
	)
	_build_branch(
		Vector2i(0, -1), down_len,
		SLUM_MAIN_POOL, SLUM_SIDE_LEFT_POOL, SLUM_SIDE_RIGHT_POOL,
		RoomType.SLUM_PRE_BOSS, RoomType.BOSS_TROLL, false
	)

func change_room(direction: Vector2i) -> void:
	var next := current_room_pos + direction
	if not map_data.has(next):
		push_warning("FloorManager: нет комнаты по адресу %s" % str(next))
		return
	current_room_pos = next
	visited_rooms[current_room_pos] = true   #6 отмечаем как посещённую
	load_current_room_scene()

func load_current_room_scene() -> void:
	var room_type: int = map_data.get(current_room_pos, RoomType.START)
	var path: String   = ROOM_SCENES.get(room_type, "")
	if path.is_empty():
		push_error("FloorManager: нет сцены для типа %d" % room_type)
		return
	print("[FloorManager] Загружаем комнату %s → тип %d → %s" % [
		str(current_room_pos), room_type, path
	])
	get_tree().call_deferred("change_scene_to_file", path)

func is_side_room() -> bool:
	return abs(current_room_pos.x) == 1

func current_room_type() -> int:
	return map_data.get(current_room_pos, RoomType.START)

# ─────────────────────────────────────────────────────────────
#  Генерация ветки
# ─────────────────────────────────────────────────────────────
func _build_branch(
	dir: Vector2i,
	length: int,
	main_pool: Array,
	side_left_pool: Array,
	side_right_pool: Array,
	pre_boss_type: int,
	boss_type: int,
	is_city: bool
) -> void:
	length = max(length, 3)
	var random_count := length - 2   # за вычетом пре-босс и босс

	var prev_had_side := false

	for i in range(1, random_count + 1):
		var room_pos := dir * i
		map_data[room_pos] = _pick_main_room(main_pool, is_city)

		if not prev_had_side and randf() < 0.5:
			var left_pos  := room_pos + Vector2i(-1, 0)
			var right_pos := room_pos + Vector2i( 1, 0)

			if not map_data.has(left_pos):
				map_data[left_pos] = _pick_side_room(side_left_pool, is_city, true)

			if randf() < 0.6 and not map_data.has(right_pos):
				map_data[right_pos] = _pick_side_room(side_right_pool, is_city, false)

			prev_had_side = true
		else:
			prev_had_side = false

	map_data[dir * (random_count + 1)] = pre_boss_type
	map_data[dir * length]             = boss_type

# ─────────────────────────────────────────────────────────────
#  Выбор комнаты из пула
# ─────────────────────────────────────────────────────────────
func _pick_main_room(pool: Array, is_city: bool) -> int:
	if is_city and not _city_garden_placed and randf() < 0.35:
		_city_garden_placed = true
		return RoomType.CITY_GARDEN
	return _weighted_pick(pool)

func _pick_side_room(pool: Array, is_city: bool, is_left: bool) -> int:
	if not is_city and not is_left and not _slum_fire_placed:
		var result := _weighted_pick(pool)
		if result == RoomType.SLUM_FIRE:
			_slum_fire_placed = true
		return result

	var filtered_pool := pool.filter(
		func(e): return not (not is_city and not is_left and e[0] == RoomType.SLUM_FIRE and _slum_fire_placed)
	)
	if filtered_pool.is_empty():
		return RoomType.SLUM_EMPTY_FOG
	return _weighted_pick(filtered_pool)

func _weighted_pick(pool: Array) -> int:
	var total := 0
	for e in pool:
		total += e[1]
	var roll := randi_range(0, total - 1)
	var acc  := 0
	for e in pool:
		acc += e[1]
		if roll < acc:
			return e[0]
	return pool[0][0]
