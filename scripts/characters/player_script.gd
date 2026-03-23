extends CharacterBody2D

var speed: float = 200.0
var damage: float = 10.0
var hp: float = 100.0

var is_dead: bool = false

var projectile_scene = preload("res://scenes/mechanics/projectile.tscn")

@onready var color_rect = $ColorRect
@onready var aim_pivot = $AimPivot
@onready var weapon_indicator = $AimPivot/WeaponIndicator
@onready var attack_cooldown_timer = $AttackCooldown
@onready var invincibility_timer = $InvincibilityTimer

@onready var melee_hitbox = $AimPivot/MeleeHitbox
@onready var scythe_hitbox = $AimPivot/MeleeHitbox/ScytheHitbox
@onready var sword_hitbox = $AimPivot/MeleeHitbox/SwordHitbox

var extra_projectiles: int = 0
var is_melee_character: bool = false
var weapon_type: int = 0
var active_hitbox: CollisionPolygon2D = null

func _ready():
	if Global.current_character_data != null:
		speed = Global.current_character_data.move_speed + Global.bonus_speed
		damage = Global.current_character_data.attack_damage + Global.bonus_damage
		color_rect.color = Global.current_character_data.placeholder_color
		attack_cooldown_timer.wait_time = Global.current_character_data.attack_cooldown
		extra_projectiles = Global.extra_projectiles

		is_melee_character = Global.current_character_data.is_melee
		weapon_type = Global.current_character_data.melee_weapon_type

		if is_melee_character:
			weapon_indicator.visible = false
			if weapon_type == 1:
				active_hitbox = sword_hitbox
			elif weapon_type == 2:
				active_hitbox = scythe_hitbox

		hp = Global.current_hp

func _physics_process(_delta):
	if is_dead:
		return

	# 1. ДВИЖЕНИЕ
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * speed
	move_and_slide()

	# 2. ПРИЦЕЛИВАНИЕ И АТАКА
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir.length() > 0:
		aim_pivot.rotation = aim_dir.angle()
		if attack_cooldown_timer.is_stopped():
			perform_attack(aim_dir.normalized())
			attack_cooldown_timer.start()

func perform_attack(dir: Vector2):
	if is_melee_character:
		# ЛОГИКА БЛИЖНЕГО БОЯ
		if active_hitbox != null:
			active_hitbox.disabled = false
			color_rect.modulate = Color(1, 1, 0)
			await get_tree().create_timer(0.15).timeout
			if not is_instance_valid(self): return
			active_hitbox.disabled = true
			color_rect.modulate = Color(1, 1, 1)
	else:
		# ЛОГИКА ДАЛЬНЕГО БОЯ
		var total_projectiles = 1 + extra_projectiles
		var spread_angle = deg_to_rad(15)
		var base_angle = dir.angle()
		var start_angle = base_angle - (spread_angle * (total_projectiles - 1) / 2.0)

		for i in range(total_projectiles):
			var proj = projectile_scene.instantiate()
			var current_angle = start_angle + (i * spread_angle)
			proj.direction = Vector2.RIGHT.rotated(current_angle)
			proj.damage = damage
			proj.speed = Global.current_character_data.projectile_speed
			proj.lifespan = Global.current_character_data.projectile_lifespan
			proj.pierce_enemies = Global.current_character_data.pierce_enemies
			proj.global_position = weapon_indicator.global_position
			get_tree().current_scene.add_child(proj)

func take_damage(amount: float):
	if is_dead or not invincibility_timer.is_stopped(): return

	hp -= amount
	Global.current_hp = hp

	if hp <= 0:
		is_dead = true

	invincibility_timer.start()
	color_rect.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(self): return
	color_rect.modulate = Color(1, 1, 1)

	if is_dead:
		die()

func die():
	visible = false
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")

func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body.is_in_group("player"):
		body.take_damage(damage)

func collect_item(item: ItemData):
	hp = minf(hp + item.heal_hp, Global.current_character_data.max_hp)
	Global.current_hp = hp

	damage += item.add_damage
	speed += item.add_speed
	extra_projectiles += item.add_projectiles
	Global.bonus_damage += item.add_damage
	Global.bonus_speed += item.add_speed
	Global.extra_projectiles += item.add_projectiles
	Global.bombs += item.add_bombs
	Global.cleansers += item.add_cleansers

	color_rect.modulate = Color(0, 1, 0)
	await get_tree().create_timer(0.2).timeout
	if not is_instance_valid(self): return
	color_rect.modulate = Color(1, 1, 1)
