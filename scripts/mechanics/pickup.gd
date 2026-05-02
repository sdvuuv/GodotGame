extends Area2D

@export var item_data: ItemData
@export var is_shop_item: bool = false

@onready var color_rect = $ColorRect

func _ready():
	if item_data == null:
		print("[Pickup] ОШИБКА: item_data = null!")
		return

	print("[Pickup] Предмет: %s | Цена: %d | is_shop: %s" % [
		item_data.item_name, item_data.price, str(is_shop_item)
	])

	color_rect.color = item_data.item_color

	if is_shop_item and item_data.price > 0:
		_create_price_label()
		print("[Pickup] Лейбл цены создан для: %s" % item_data.item_name)
	else:
		print("[Pickup] Не магазин или цена = 0, лейбл не создаётся")

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

	print("[Pickup] Игрок коснулся: %s | Монет: %d | Цена: %d | is_shop: %s" % [
		item_data.item_name, Global.coins, item_data.price, str(is_shop_item)
	])

	if is_shop_item:
		if Global.coins >= item_data.price:
			print("[Pickup] Куплено: %s" % item_data.item_name)
			Global.coins -= item_data.price
			body.collect_item(item_data)
			queue_free()
		else:
			print("[Pickup] Не хватает монет! Нужно: %d, есть: %d" % [item_data.price, Global.coins])
			color_rect.color = Color(1, 0.2, 0.2)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(self):
				color_rect.color = item_data.item_color
	else:
		print("[Pickup] Подобрано бесплатно: %s" % item_data.item_name)
		body.collect_item(item_data)
		queue_free()
