extends Control

func _on_play_button_pressed():
	# Переход на экран выбора персонажа
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")

func _on_quit_button_pressed():
	# Выход из игры
	get_tree().quit()
