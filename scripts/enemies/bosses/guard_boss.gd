extends BaseBoss

var is_attacking: bool = false
var phase: int = 1
var shield_active: bool = false
var shield_timer: float = 0.0
var shield_cooldown: float = 20.0

@onready var anim = $ColorRect
@onready var aim_pivot = $AimPivot
@onready var sword = $AimPivot/Sword

var guard_scene = preload("res://scenes/characters/enemies/guard.tscn")

func _ready():
	super()
	sword.visible = false
	anim.play("idle")

func _physics_process(delta):
	if player == null or is_attacking: return

	_update_phase()
	_update_shield(delta)

	if shield_active: return

	aim_pivot.look_at(player.global_position)
	anim.flip_h = (player.global_position.x < global_position.x)

	var dist = global_position.distance_to(player.global_position)
	var current_speed = speed * (1.0 + (phase - 1) * 0.3)

	if dist < 70.0:
		spin_attack()
	elif dist < 180.0:
		lunge_attack()
	else:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * current_speed
		move_and_slide()
		anim.play("run")

func _update_phase():
	var hp_pct = hp / 100.0
	var old_phase = phase

	if hp_pct > 0.6:
		phase = 1
	elif hp_pct > 0.3:
		phase = 2
	else:
		phase = 3

	# Переход в новую фазу
	if phase != old_phase:
		_on_phase_changed(phase)

func _on_phase_changed(new_phase: int):
	if new_phase == 2:
		# Вспышка — становится быстрее
		anim.modulate = Color(1, 0.5, 0)
		await get_tree().create_timer(0.5).timeout
		if not is_instance_valid(self): return
		anim.modulate = Color(1, 1, 1)
		speed *= 1.3

	elif new_phase == 3:
		# Крик страха — дрейн рассудка персонажам с тегом elfian
		_fear_scream()
		# Призыв двух гвардейцев
		await get_tree().create_timer(0.8).timeout
		if not is_instance_valid(self): return
		_spawn_guards()
		speed *= 1.2

func _fear_scream():
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(self): return
	anim.modulate = Color(1, 1, 1)

	if Global.current_character_data == null: return
	if "elfian" in Global.current_character_data.feared_tags:
		Global.current_sanity -= 20.0

func _spawn_guards():
	var offsets = [Vector2(-120, 0), Vector2(120, 0)]
	for offset in offsets:
		var guard = guard_scene.instantiate()
		guard.global_position = global_position + offset
		get_tree().current_scene.add_child(guard)

func _update_shield(delta: float):
	shield_timer += delta
	if shield_timer >= shield_cooldown and not shield_active and not is_attacking:
		shield_timer = 0.0
		_activate_shield()

func _activate_shield():
	shield_active = true
	anim.modulate = Color(0.3, 0.3, 1.0)  # синий = щит
	velocity = Vector2.ZERO

	await get_tree().create_timer(2.0).timeout
	if not is_instance_valid(self): return

	shield_active = false
	anim.modulate = Color(1, 1, 1)
	# Контратака сразу после щита
	if player != null:
		_dash_behind_player()

func _dash_behind_player():
	if player == null: return
	# Рывок за спину игрока
	var behind = player.global_position + (player.global_position - global_position).normalized() * 80
	anim.modulate = Color(1, 1, 0)  # жёлтый = рывок
	var tween = create_tween()
	tween.tween_property(self, "global_position", behind, 0.15)
	await tween.finished
	if not is_instance_valid(self): return
	anim.modulate = Color(1, 1, 1)
	lunge_attack()

func take_damage(amount: float):
	if is_dead: return
	# Щит блокирует урон
	if shield_active:
		anim.modulate = Color(0.5, 0.5, 1.0)
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self): return
		anim.modulate = Color(0.3, 0.3, 1.0)
		return
	super(amount)

func spin_attack():
	is_attacking = true
	anim.play("attack")
	anim.modulate = Color(1, 0.5, 1)
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self): return
	sword.visible = true
	var tween = create_tween()
	# В фазе 3 крутится быстрее
	var spin_time = 0.4 if phase < 3 else 0.25
	tween.tween_property(aim_pivot, "rotation", aim_pivot.rotation + TAU, spin_time)
	for i in range(4):
		await get_tree().create_timer(spin_time / 4).timeout
		if not is_instance_valid(self): return
		for body in sword.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(attack_damage)
	await tween.finished
	if not is_instance_valid(self): return
	sword.visible = false
	anim.modulate = Color(1, 1, 1)
	anim.play("run")
	# В фазе 3 сразу снова атакует
	var cooldown = 1.0 if phase < 3 else 0.3
	await get_tree().create_timer(cooldown).timeout
	if not is_instance_valid(self): return
	is_attacking = false

func lunge_attack():
	is_attacking = true
	anim.play("attack")
	# В фазе 2+ мигает быстрее
	var blink_time = 0.15 if phase == 1 else 0.08
	for i in range(3):
		anim.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(blink_time).timeout
		if not is_instance_valid(self): return
		anim.modulate = Color(1, 1, 1)
		await get_tree().create_timer(blink_time).timeout
		if not is_instance_valid(self): return
	sword.visible = true
	var tween = create_tween()
	tween.tween_property(sword, "scale", Vector2(3.0, 1.0), 0.2)
	await tween.finished
	if not is_instance_valid(self): return
	for body in sword.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(attack_damage)
	var tween_back = create_tween()
	tween_back.tween_property(sword, "scale", Vector2(1.0, 1.0), 0.1)
	await tween_back.finished
	if not is_instance_valid(self): return
	sword.visible = false
	anim.play("run")
	var cooldown = 1.0 if phase < 2 else 0.6
	await get_tree().create_timer(cooldown).timeout
	if not is_instance_valid(self): return
	is_attacking = false
