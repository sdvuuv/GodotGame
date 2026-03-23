extends Area2D

var direction: Vector2 = Vector2.ZERO
var damage: float = 10.0

var speed: float = 400.0
var lifespan: float = 1.0
var pierce_enemies: bool = false

@onready var timer = $Timer

func _ready():
	timer.start(lifespan)

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		if not pierce_enemies:
			queue_free()
