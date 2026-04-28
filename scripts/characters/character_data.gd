extends Resource
class_name CharacterData

@export var id: int
@export var character_name: String
@export var description: String
@export var placeholder_color: Color 
@export var feared_tags: Array[String] = []
@export var sanity_drain_per_second: float = 5.0
@export var max_hp: float = 100.0
@export var max_sanity: float = 100.0
@export var move_speed: float = 200.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 0.5
@export var projectile_speed: float = 400.0 # Скорость полета
@export var projectile_lifespan: float = 1.0 # Время жизни (дальность)
@export var pierce_enemies: bool = false # Прошивает ли врагов?
@export var is_melee: bool = false
# 0 - Нет (Ренжевик), 1 - Меч, 2 - Коса
@export var melee_weapon_type: int = 0
@export var has_custom_sanity_behavior: bool = false
