extends Resource
class_name LootTable

@export var consumables: Array[ItemData] = [] # Расходники
@export var melee_items: Array[ItemData] = [] # Предметы для Воина/Мины
@export var ranged_items: Array[ItemData] = [] # Предметы для Мага/Лучника

# Функция, которая выдает случайный расходник
func get_random_consumable() -> ItemData:
	if consumables.is_empty(): return null
	return consumables.pick_random() 
# Функция, которая выдает случайный предмет в зависимости от класса
func get_random_stat_item(is_melee: bool) -> ItemData:
	var pool = melee_items if is_melee else ranged_items
	if pool.is_empty(): return null
	return pool.pick_random()
