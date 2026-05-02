extends BaseRoom

var pickup_scene = preload("res://scenes/items/pickup.tscn")

const ITEM_POSITIONS = [
	Vector2(466, 236),
	Vector2(577, 236),
	Vector2(666, 236),
]

func _ready() -> void:
	super._ready()
	_spawn_shop_items()

func _spawn_shop_items() -> void:
	var items = Global.loot.get_random_shop_items(ITEM_POSITIONS.size())
	for i in range(items.size()):
		var pickup = pickup_scene.instantiate()
		pickup.item_data = items[i]
		pickup.is_shop_item = true
		pickup.position = ITEM_POSITIONS[i]
		add_child(pickup)
