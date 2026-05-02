extends BaseEnemy

var enemy_projectile_scene = preload("res://scenes/mechanics/enemy_projectile.tscn")
@onready var shoot_timer = $ShootTimer
@onready var anim = $ColorRect
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var wander_interval: float = 2.0 

# --- Уклонение от игрока ---
const FLEE_DISTANCE = 120.0 
const WANDER_SPEED_MULT = 0.5 

func _ready():
	super()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()
	_pick_new_wander_direction()

func _physics_process(delta):
	if player == null:
		return

	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_direction()

	var distance = global_position.distance_to(player.global_position)

	if distance < FLEE_DISTANCE:
		var flee_dir = (global_position - player.global_position).normalized()
		velocity = flee_dir * speed * 0.7
	else:
		velocity = wander_direction * speed * WANDER_SPEED_MULT

	move_and_slide()

func _pick_new_wander_direction():
	var angle = randf_range(0, TAU)
	wander_direction = Vector2(cos(angle), sin(angle))
	wander_interval = randf_range(1.5, 3.0)
	wander_timer = wander_interval

func _on_shoot_timer_timeout():
	if player != null:
		shoot_fan()
	shoot_timer.start() 

func shoot_fan():
	anim.modulate = Color(1, 1, 0)
	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(self): return
	anim.modulate = Color(0, 1, 0)

	if player == null: return

	var dir_to_player = (player.global_position - global_position).normalized()
	var base_angle = dir_to_player.angle()

	for i in range(3):
		var proj = enemy_projectile_scene.instantiate()
		var spread = deg_to_rad(20)
		proj.direction = Vector2.RIGHT.rotated(base_angle + (i - 1) * spread)
		proj.damage = attack_damage
		proj.global_position = global_position
		get_tree().current_scene.add_child(proj)
