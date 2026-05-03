extends Area2D

var player_in_range: bool = false

@export_multiline var dialogue: String = "Welcome to the city, stranger.\nThings have been uneasy here for a while —\nthe guards have become obedient puppets,\nand something terrible lurks in the slums."

signal show_text(text: String)
signal hide_text()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		show_text.emit(dialogue)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		hide_text.emit()
