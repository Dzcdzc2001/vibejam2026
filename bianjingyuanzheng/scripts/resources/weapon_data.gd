class_name WeaponData
extends Resource

enum WeaponType { SWORD = 0, BOW = 1, STAFF = 2, SHIELD = 3 }

@export var weapon_id: String = ""
@export var display_name: String = ""
@export var weapon_type: int = 0
@export var forge_material_id: String = ""
@export var material_quality: int = 0
@export var base_atk_min: int = 50
@export var base_atk_max: int = 100
@export var element_type: String = "neutral"
@export var element_bonus: float = 1.0
@export var creativity_bonus: int = 0
@export var counter_bonus: float = 1.0
@export var level: int = 1
@export var enchant_slots: int = 1
@export var active_enchants: Array[EnchantData] = []
@export var upgrade_cost: Dictionary = {}
@export var upgrade_result: String = ""
