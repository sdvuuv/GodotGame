extends CanvasLayer
@onready var overlay   = $Overlay
@onready var label     = $GameOverLabel
@onready var btn_retry = $RetryButton
@onready var btn_menu  = $MenuButton

func _ready():
	overlay.modulate.a   = 0.0
	label.modulate.a     = 0.0
	btn_retry.modulate.a = 0.0
	btn_menu.modulate.a  = 0.0
	label.modulate.a = 1.0
	_animate()

func _animate():
	var tween = create_tween()
	# overlay затемняется сразу
	tween.tween_property(overlay, "modulate:a", 0.85, 0.8)
	# после overlay — появляется текст
	tween.tween_property(label, "modulate:a", 1.0, 0.7)
	# потом кнопки одна за другой
	tween.tween_property(btn_retry, "modulate:a", 1.0, 0.5)
	tween.tween_property(btn_menu,  "modulate:a", 1.0, 0.5)
func _on_retry_pressed():
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")

func _on_menu_pressed():
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
