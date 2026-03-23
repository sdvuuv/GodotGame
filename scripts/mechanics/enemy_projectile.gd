extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 200.0 
var damage: float = 15.0

func _ready():
	$Timer.start(2.0)
	

func _physics_process(delta):
	position += direction * speed * delta

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		return
		
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() 
