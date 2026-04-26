class_name MaterialData
extends Resource

enum MaterialType { MINERAL = 0, MONSTER_PART = 1 }
enum Quality { COMMON = 0, RARE = 1, LEGENDARY = 2 }

@export var material_id: String = ""
@export var display_name: String = ""
@export var material_type: int = 0
@export var quality: int = 0
@export var source_region: String = ""
@export var source_monster: String = ""
@export var drop_rate: float = 0.0
@export var description: String = ""
@export var atk_range: Vector2 = Vector2(50, 100)
