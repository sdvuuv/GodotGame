extends CanvasLayer

@onready var overlay  = $Overlay
@onready var label    = $VictoryLabel
@onready var sublabel = $SubLabel
@onready var btn_menu = $MenuButton

func _ready():
	overlay.modulate.a  = 0.0
	label.modulate.a    = 0.0
	sublabel.modulate.a = 0.0
	btn_menu.modulate.a = 0.0
	_animate()

func _animate():
	var tween = create_tween()
	tween.tween_property(overlay,  "modulate:a", 1.0, 1.5)
	tween.tween_property(label,    "modulate:a", 1.0, 1.0)
	tween.tween_property(sublabel, "modulate:a", 1.0, 0.8)
	tween.tween_property(btn_menu, "modulate:a", 1.0, 0.6)

func _on_menu_pressed():
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
