class_name MonsterData
extends Resource

enum MonsterType { NORMAL = 0, ELITE = 1, BOSS = 2 }

@export var id: String = ""
@export var display_name: String = ""
@export var monster_type: int = 0
@export var extinct_species_id: String = ""
@export var animal_trait_desc: String = ""
@export var region_adaptation: String = ""
@export var environment_bonus: Dictionary = {}
@export var base_hp: int = 50
@export var base_atk: int = 10
@export var base_def: int = 5
@export var base_spd: int = 10
@export var base_res: int = 5
@export var region_type: String = ""
@export var weather_bonus: Dictionary = {}
@export var weather_weakness: Dictionary = {}
@export var instant_skills: Array[SkillData] = []
@export var charge_skills: Array[SkillData] = []
@export var passive_skills: Array[SkillData] = []
@export var drop_table: Dictionary = {}
@export var exp_reward: int = 30
@export var bestiary_id: String = ""
@export var intro_text: String = ""
@export var charge_alert_text: String = ""
