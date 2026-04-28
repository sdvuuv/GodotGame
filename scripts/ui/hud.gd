extends CanvasLayer
 
@onready var health_bar = $Control/ProgressBar
@onready var sanity_bar = $Control/SanityBar
@onready var minimap = $Control/Minimap
@onready var vignette   = $Vignette 
func _process(_delta: float) -> void:
	if is_instance_valid(minimap):
		minimap.queue_redraw() 
func _ready():
	if Global.current_character_data != null:
		health_bar.max_value = Global.current_character_data.max_hp
		health_bar.value = Global.current_hp
		sanity_bar.max_value = Global.current_character_data.max_sanity
		sanity_bar.value = Global.current_sanity
 
	Global.hp_changed.connect(_on_hp_changed)
	Global.sanity_changed.connect(_on_sanity_changed)
 

func _on_hp_changed(new_hp: float):
	health_bar.value = new_hp
 
func _on_sanity_changed(new_sanity: float):  # ← новая функция
	if Global.current_character_data == null: return

	var pct = new_sanity / Global.current_character_data.max_sanity
	var mat = vignette.material as ShaderMaterial
	if mat == null: return

	if Global.current_character_data.has_custom_sanity_behavior:
		mat.set_shader_parameter("color", Vector3(0.6, 0.0, 0.0))
	else:
		mat.set_shader_parameter("color", Vector3(0.0, 0.0, 0.0))

	var intensity = clampf(1.0 - pct, 0.0, 1.0)
	intensity = clampf((intensity - 0.25) / 0.75, 0.0, 1.0)
	mat.set_shader_parameter("intensity", intensity)
	if not Global.current_character_data.has_custom_sanity_behavior:
		$Control.visible = pct > 0.1
	if not Global.current_character_data.has_custom_sanity_behavior:
		if pct < 0.5:
			minimap.glitch_intensity = clampf((0.5 - pct) / 0.5, 0.0, 1.0)
		else:
			minimap.glitch_intensity = 0.0
