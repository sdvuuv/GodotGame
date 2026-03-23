extends BaseEnemy

@onready var damage_zone = $DamageZone
var attack_cooldown: float = 0.0
func _ready():
	super()

func _physics_process(delta):
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Кусает постоянно вблизи
		var overlapping_bodies = damage_zone.get_overlapping_bodies()
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			for body in damage_zone.get_overlapping_bodies():
				if body.is_in_group("player"):
					body.take_damage(attack_damage)
					attack_cooldown = 0.8
