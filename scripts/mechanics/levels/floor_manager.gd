extends Node

# Ключ: Vector2, Значение: String (тип комнаты)
var map_data: Dictionary = {}

# Текущая позиция игрока на карте
var current_room_pos: Vector2 = Vector2.ZERO

var cleared_rooms: Dictionary = {}

var room_scenes: Dictionary = {
	"StartRoom":        "res://scenes/levels/start_room.tscn",
	"City_Street":      "res://scenes/levels/city_street.tscn",
	"Boss_GuardOfficer":"res://scenes/levels/boss_room.tscn",
	"Slums_Street":     "res://scenes/levels/city_street.tscn",
	"Boss_Troll":       "res://scenes/levels/boss_room.tscn"
}

func generate_first_floor():
	cleared_rooms.clear()
	map_data.clear()
	current_room_pos = Vector2.ZERO

	# 1. СТАРТОВАЯ КОМНАТА
	map_data[Vector2.ZERO] = "StartRoom"

	# 2. ВЕРХНЯЯ ВЕТКА (Город, 3-5 комнат, босс в конце)
	var up_length = randi_range(3, 5)
	for i in range(1, up_length + 1):
		map_data[Vector2(0, i)] = "Boss_GuardOfficer" if i == up_length else "City_Street"

	# 3. НИЖНЯЯ ВЕТКА (Трущобы, 3-5 комнат, босс в конце)
	var down_length = randi_range(3, 5)
	for i in range(1, down_length + 1):
		map_data[Vector2(0, -i)] = "Boss_Troll" if i == down_length else "Slums_Street"

func change_room(direction_vector: Vector2):
	var next_pos = current_room_pos + direction_vector

	if not map_data.has(next_pos):
		push_warning("FloorManager: попытка войти в несуществующую комнату " + str(next_pos))
		return

	current_room_pos = next_pos
	load_current_room_scene()

func load_current_room_scene():
	var room_type = map_data[current_room_pos]

	if room_scenes.has(room_type):
		get_tree().call_deferred("change_scene_to_file", room_scenes[room_type])
	else:
		push_error("FloorManager: нет сцены для комнаты типа '" + room_type + "'")
