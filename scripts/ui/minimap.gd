extends Control

const ROOM_SIZE  := Vector2(14.0, 10.0)
const ROOM_GAP   := Vector2(4.0,  4.0)
const MAP_OFFSET := Vector2(10.0, 10.0)

const COLOR_CURRENT  := Color("#f0c060")
const COLOR_VISITED  := Color("#6a5a8a")
const COLOR_BORDER   := Color("#4a3a5a")
const COLOR_BOSS     := Color("#8b3a6b")
const COLOR_REWARD   := Color("#3d1f4f")
const COLOR_SHOP     := Color("#3a6b5a")
const COLOR_START    := Color("#3a6b8a")

func _draw() -> void:
	if FloorManager.map_data.is_empty():
		return

	var min_x: int = 999
	var max_x: int = -999
	var min_y: int = 999
	var max_y: int = -999

	for pos in FloorManager.map_data.keys():
		var p := pos as Vector2i
		min_x = min(min_x, p.x); max_x = max(max_x, p.x)
		min_y = min(min_y, p.y); max_y = max(max_y, p.y)

	var map_width: float  = (max_x - min_x + 1) * (ROOM_SIZE.x + ROOM_GAP.x)
	var map_height: float = (max_y - min_y + 1) * (ROOM_SIZE.y + ROOM_GAP.y)

	draw_rect(Rect2(
		MAP_OFFSET - Vector2(4, 4),
		Vector2(map_width + 8, map_height + 8)
	), Color(0, 0, 0, 0.6), true)

	for room_pos in FloorManager.map_data.keys():
		var rp := room_pos as Vector2i
		if _is_known(rp):
			_draw_corridors(rp, min_x, max_y)

	for room_pos in FloorManager.map_data.keys():
		var rp := room_pos as Vector2i
		var room_type: int = FloorManager.map_data[rp]
		var is_current: bool = rp == FloorManager.current_room_pos
		var is_known: bool   = _is_known(rp)

		var draw_x: float = MAP_OFFSET.x + (rp.x - min_x) * (ROOM_SIZE.x + ROOM_GAP.x)
		var draw_y: float = MAP_OFFSET.y + (max_y - rp.y) * (ROOM_SIZE.y + ROOM_GAP.y)
		var rect := Rect2(Vector2(draw_x, draw_y), ROOM_SIZE)

		if not is_known:
			draw_rect(rect, COLOR_BORDER, false, 1.0)
			continue

		var color: Color = _get_room_color(rp, room_type)
		draw_rect(rect, color, true)
		draw_rect(rect, COLOR_BORDER, false, 1.0)

		if is_current:
			draw_circle(
				Vector2(draw_x + ROOM_SIZE.x / 2.0, draw_y + ROOM_SIZE.y / 2.0),
				2.5,
				Color(1, 1, 1)
			)

func _is_known(pos: Vector2i) -> bool:
	if FloorManager.visited_rooms.has(pos):
		return true
	for dir in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0)]:
		if FloorManager.visited_rooms.has(pos + dir):
			return true
	return false

func _draw_corridors(room_pos: Vector2i, min_x: int, max_y: int) -> void:
	var neighbors: Array[Vector2i] = [Vector2i(0,1), Vector2i(0,-1), Vector2i(-1,0), Vector2i(1,0)]
	for dir in neighbors:
		var neighbor: Vector2i = room_pos + dir
		if not FloorManager.map_data.has(neighbor):
			continue
		if not _is_known(neighbor):
			continue

		var ax: float = MAP_OFFSET.x + (room_pos.x - min_x) * (ROOM_SIZE.x + ROOM_GAP.x) + ROOM_SIZE.x / 2.0
		var ay: float = MAP_OFFSET.y + (max_y - room_pos.y) * (ROOM_SIZE.y + ROOM_GAP.y) + ROOM_SIZE.y / 2.0
		var bx: float = MAP_OFFSET.x + (neighbor.x  - min_x) * (ROOM_SIZE.x + ROOM_GAP.x) + ROOM_SIZE.x / 2.0
		var by: float = MAP_OFFSET.y + (max_y - neighbor.y)  * (ROOM_SIZE.y + ROOM_GAP.y) + ROOM_SIZE.y / 2.0

		draw_line(Vector2(ax, ay), Vector2(bx, by), COLOR_BORDER, 1.5)

func _get_room_color(room_pos: Vector2i, room_type: int) -> Color:
	if room_pos == FloorManager.current_room_pos:
		return COLOR_CURRENT
	var rt := FloorManager.RoomType
	match room_type:
		rt.BOSS_GUARD, rt.BOSS_TROLL:
			return COLOR_BOSS
		rt.CITY_ROYAL_GARDEN:
			return COLOR_REWARD
		rt.CITY_SHOP, rt.SLUM_SHOP:
			return COLOR_SHOP
		rt.START:
			return COLOR_START
	return COLOR_VISITED
