extends Area2D

@export var item_data: ItemData 

@onready var color_rect = $ColorRect

func _ready():
	if item_data != null:
		color_rect.color = item_data.item_color

func _on_body_entered(body):
	if body.is_in_group("player") and item_data != null:
		if body.has_method("collect_item"):
			body.collect_item(item_data)
			queue_free() 
