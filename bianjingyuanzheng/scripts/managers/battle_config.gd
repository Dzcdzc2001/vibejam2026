class_name BattleConfig
extends RefCounted

static var pending_monster: MonsterData = null
static var pending_monster_instance: Dictionary = {}
static var from_region: String = ""
static var current_weather: String = "clear"

static func clear() -> void:
	pending_monster = null
	pending_monster_instance = {}
	from_region = ""
	current_weather = "clear"
