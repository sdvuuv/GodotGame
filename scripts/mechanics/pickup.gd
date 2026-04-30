extends Area2D

@export var item_data: ItemData

@onready var color_rect = $ColorRect

var price_label: Label = null
var is_shop_item: bool = false

func _ready():
	if item_data != null:
		color_rect.color = item_data.item_color

		if item_data.price > 0:
			is_shop_item = true
			price_label = Label.new()
			price_label.text = "🪙 %d" % item_data.price
			price_label.position = Vector2(-16, -28)
			price_label.add_theme_font_size_override("font_size", 14)
			add_child(price_label)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"): return
	if item_data == null: return

	if is_shop_item:
		if Global.coins >= item_data.price:
			Global.coins -= item_data.price
			body.collect_item(item_data)
			queue_free()
		else:
			color_rect.color = Color(1, 0.2, 0.2)
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(self):
				color_rect.color = item_data.item_color
	else:
		body.collect_item(item_data)
		queue_free()
