class_name PlayerData
extends RefCounted

static var _instance: PlayerData = null

var player_name: String = "远征队长"
var level: int = 1
var exp: int = 0
var free_points: int = 0
var base_atk: int = 10
var base_def: int = 10
var base_hp: int = 100
var base_spd: int = 10
var parsing_power: int = 0
var gold: int = 0
var equipped_weapon: WeaponData = null
var inventory: Dictionary = {}
var bestiary: Dictionary = {}
var conquered_regions: Array[String] = []
var current_region_scene: String = ""

static func get_instance() -> PlayerData:
	if _instance == null:
		_instance = PlayerData.new()
	return _instance

func add_item(item_id: String, count: int) -> void:
	if inventory.has(item_id):
		inventory[item_id] += count
	else:
		inventory[item_id] = count
	EventBus.item_obtained.emit(item_id, count)

func has_item(item_id: String, count: int = 1) -> bool:
	return inventory.get(item_id, 0) >= count

func remove_item(item_id: String, count: int) -> bool:
	if not has_item(item_id, count):
		return false
	inventory[item_id] -= count
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	return true

func add_exp(amount: int) -> void:
	exp += amount
	while exp >= _exp_to_next_level():
		exp -= _exp_to_next_level()
		level += 1
		free_points += 3
		base_hp += 20
		base_spd += 2
		EventBus.player_leveled_up.emit(level)

func _exp_to_next_level() -> int:
	return 100 + (level - 1) * 50

func unlock_bestiary(species_id: String) -> void:
	if not bestiary.has(species_id):
		bestiary[species_id] = true
		base_hp += 10
		EventBus.bestiary_unlocked.emit(species_id)
		if bestiary.size() % 5 == 0:
			parsing_power += 5
			EventBus.bestiary_milestone.emit(bestiary.size())

func conquer_region(region_id: String) -> void:
	if not conquered_regions.has(region_id):
		conquered_regions.append(region_id)
		add_exp(2000)
		EventBus.territory_conquered.emit(region_id)

func to_dict() -> Dictionary:
	return {
		"name": player_name, "level": level, "exp": exp,
		"free_points": free_points,
		"base_atk": base_atk, "base_def": base_def,
		"base_hp": base_hp, "base_spd": base_spd,
		"parsing_power": parsing_power, "gold": gold,
		"equipped_weapon_id": equipped_weapon.weapon_id if equipped_weapon else "",
		"inventory": inventory,
		"bestiary": bestiary,
		"conquered_regions": conquered_regions,
		"current_region_scene": current_region_scene
	}

func from_dict(data: Dictionary) -> void:
	player_name = data.get("name", "远征队长")
	level = data.get("level", 1); exp = data.get("exp", 0)
	free_points = data.get("free_points", 0)
	base_atk = data.get("base_atk", 10); base_def = data.get("base_def", 10)
	base_hp = data.get("base_hp", 100); base_spd = data.get("base_spd", 10)
	parsing_power = data.get("parsing_power", 0); gold = data.get("gold", 0)
	inventory = data.get("inventory", {}) as Dictionary
	bestiary = data.get("bestiary", {}) as Dictionary
	conquered_regions.assign(data.get("conquered_regions", []))
	current_region_scene = data.get("current_region_scene", "") as String
