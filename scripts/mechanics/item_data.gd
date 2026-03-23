extends Resource
class_name ItemData

@export var item_name: String = "Новый предмет"
@export_multiline var description: String = ""
@export var tier: int = 1 # Уровень (1-4)
@export var item_color: Color = Color(1, 1, 0) 

@export_category("Статы (0 = не меняет)")
@export var heal_hp: float = 0.0
@export var heal_sanity: float = 0.0
@export var add_damage: float = 0.0
@export var add_speed: float = 0.0
@export var add_projectiles: int = 0 


@export_category("Расходники")
@export var add_bombs: int = 0
@export var add_cleansers: int = 0
