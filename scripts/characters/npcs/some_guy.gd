extends Area2D

var player_in_range: bool = false

@export_multiline var dialogue: String = "Добро пожаловать в город, чужестранец.\nЗдесь давно неспокойно — стражники\nпревратились в послушных кукол,\nа в трущобах завёлся кто-то страшный."

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
