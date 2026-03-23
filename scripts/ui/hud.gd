extends CanvasLayer
 
@onready var health_bar = $Control/ProgressBar
 
func _ready():
	if Global.current_character_data != null:
		health_bar.max_value = Global.current_character_data.max_hp
		health_bar.value = Global.current_hp
 
	Global.hp_changed.connect(_on_hp_changed)
 
func _on_hp_changed(new_hp: float):
	health_bar.value = new_hp
 
