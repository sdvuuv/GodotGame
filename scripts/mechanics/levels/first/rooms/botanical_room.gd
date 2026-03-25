extends BaseRoom

var _damage_timer: float = 0.0

func _process(delta: float) -> void:
	_damage_timer += delta
	if _damage_timer >= 2.0:
		_damage_timer = 0.0
		for p in get_tree().get_nodes_in_group("player"):
			if p.has_method("take_damage"):
				p.take_damage(5.0)
