extends Area2D

@export var item_data: ItemData

@onready var color_rect = $ColorRect

var player_in_range: bool = false

func _ready():
	if item_data != null:
		color_rect.color = item_data.item_color

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		_try_collect()

func _on_body_entered(body):
	if body.is_in_group("player") and item_data != null:
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _try_collect():
	if item_data == null: return

	if item_data.price > 0:
		# Платный предмет — проверяем монеты
		if Global.coins >= item_data.price:
			Global.coins -= item_data.price
			_collect()
		else:
			print("Недостаточно монет! Нужно: %d, есть: %d" % [item_data.price, Global.coins])
	else:
		# Бесплатный — подбираем сразу
		_collect()

func _collect():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].collect_item(item_data)
	queue_free()
