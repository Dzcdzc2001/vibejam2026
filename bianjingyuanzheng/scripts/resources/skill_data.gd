class_name SkillData
extends Resource

enum SkillType { INSTANT = 0, CHARGE = 1, PASSIVE = 2 }
enum AnimTier { SIMPLE = 0, MEDIUM = 1, FULLSCREEN = 2, SPECIAL = 3 }

@export var skill_id: String = ""
@export var display_name: String = ""
@export var skill_type: int = 0
@export var charge_turns: int = 0
@export var base_damage: int = 10
@export var damage_type: String = "physical"
@export var target_type: String = "single"
@export var effects: Array[String] = []
@export var anim_tier: int = 0
