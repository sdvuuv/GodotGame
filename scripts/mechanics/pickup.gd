extends Area2D
@export var item_data: ItemData
@export var is_shop_item: bool = false
@onready var color_rect = $ColorRect

var default_texture = preload("res://assets/sprites/item_0_19.png")

func _ready():
	if item_data == null:
		print("[Pickup] ОШИБКА: item_data = null!")
		return
	
	print("[Pickup] Предмет: %s | Цена: %d | is_shop: %s" % [
		item_data.item_name, item_data.price, str(is_shop_item)
	])
	
	# Меняем ColorRect на спрайт
	if item_data.icon != null:
		color_rect.texture = item_data.icon
	else:
		color_rect.texture = default_texture

	if is_shop_item and item_data.price > 0:
		_create_price_label()
	
func _create_price_label():
	var label = Label.new()
	label.text = "🪙 %d" % item_data.price
	label.position = Vector2(-16, -36)
	label.z_index = 10
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)

func _on_body_entered(body):
	if not body.is_in_group("player"): return
	if item_data == null: return

	if is_shop_item:
		if Global.coins >= item_data.price:
			Global.coins -= item_data.price
			body.collect_item(item_data)
			queue_free()
		else:
			color_rect.modulate = Color(1, 0.2, 0.2)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(self):
				color_rect.modulate = Color(1, 1, 1)
	else:
		body.collect_item(item_data)
		queue_free()
